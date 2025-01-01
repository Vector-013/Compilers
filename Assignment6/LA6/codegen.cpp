#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <fstream>

using namespace std;

int yylex();
void yyerror(string s);
extern int yyparse();

struct quad
{
    string op;
    string arg1;
    string arg2;
    string result;
    int alt_ins;
};

struct symbol
{
    string name;
    int regno;
    int is_temp;
    int is_const;
    int is_mem;
    struct symbol *next;
};

struct symtab
{
    symbol *head;
    struct symtab *next;
};

struct RegisterBank
{
    symtab *symbols;
};

vector<quad> quads(1000);
vector<quad> quads2(1000);
vector<int> leaders(1000);
vector<RegisterBank> reg_bank(1000);
symbol *SymbolTable;
int temp_count, next_instr, ass_instr, quad_cnt, reg_nos;

symbol *new_Symbol(const string &name, int is_temp, int is_const)
{
    symbol *tmp = new symbol;
    tmp->name = name;
    tmp->regno = -1;
    tmp->is_temp = is_temp;
    tmp->is_const = is_const;
    tmp->is_mem = 1;
    tmp->next = nullptr;
    return tmp;
}
symbol *gen_temp()
{
    string temp = "$" + to_string(temp_count++);
    symbol *t = new_Symbol(temp, 1, 0);
    if (SymbolTable == NULL)
    {
        SymbolTable = t;
        return t;
    }
    symbol *prev = SymbolTable;
    while (prev->next != NULL)
    {
        prev = prev->next;
    }
    prev->next = t;
    return t;
}
symbol *symbol_search(string name, int is_temp, int is_const)
{
    if (SymbolTable == NULL)
    {
        SymbolTable = new_Symbol(name, is_temp, is_const);
        return SymbolTable;
    }
    symbol *temp = SymbolTable;
    symbol *prev = NULL;

    while (temp != NULL)
    {
        if (temp->name == name)
            return temp;
        prev = temp;
        temp = temp->next;
    }
    symbol *t = new_Symbol(name, is_temp, is_const);
    prev->next = t;
    return t;
}

void emit(const string &op, const string &arg1, const string &arg2, const string &result, int assembly)
{
    if (assembly == 0)
    {
        quads[next_instr].op = op;
        quads[next_instr].arg1 = arg1;
        quads[next_instr].arg2 = arg2;
        quads[next_instr].result = result;
        next_instr++;
    }
    else
    {
        quads2[ass_instr].op = op;
        quads2[ass_instr].arg1 = arg1;
        quads2[ass_instr].arg2 = arg2;
        quads2[ass_instr].result = result;
        quads2[ass_instr].alt_ins = quad_cnt;
        ass_instr++;
    }
}

void print_quads()
{
    int block = 1;
    for (int i = 1; i < next_instr; i++)
    {
        if (leaders[i] != 0)
        {
            if (i != 1)
            {
                cout << "\n";
            }
            cout << "Block " << block++ << "\n";
        }
        cout << "  ";
        int type;
        if (quads[i].op == "=")
            type = 0;
        else if (quads[i].op == "gt")
            type = 1;
        else if (quads[i].op == "if")
            type = 2;

        switch (type)
        {
        case 0:
            cout << i << "\t: " << quads[i].result << " = " << quads[i].arg1 << "\n";
            continue;
            break;
        case 1:
            cout << i << "\t: goto " << quads[i].result << "\n";
            continue;
            break;
        case 2:
            cout << i << "\t: iffalse " << "(" << quads[i].arg1 << ")" << " goto " << quads[i].result << "\n";
            continue;
            break;
        }
        cout << i << "\t: " << quads[i].result << " = " << quads[i].arg1 << " " << quads[i].op << " " << quads[i].arg2 << "\n";
    }
    cout << "\n"
         << "  " << next_instr << "\t:";
}

void spill(int reg, int forced)
{
    symtab *tmp = reg_bank[reg].symbols;
    symtab *prev = NULL;
    while (tmp != NULL)
    {
        symbol *sym = tmp->head;
        if (sym->is_const == 0 && sym->is_mem == 0 && (forced == 1 || sym->is_temp == 0))
        {
            string s = "R" + to_string(reg);
            emit("ST", s, "", sym->name, 1);
        }
        sym->regno = -1;
        sym->is_mem = 1;
        prev = tmp;
        tmp = tmp->next;
        delete prev;
    }
    reg_bank[reg].symbols = NULL;
}

void remove_symbol(symbol *sym)
{
    symtab *temp = reg_bank[sym->regno].symbols;
    if (temp->head == sym)
    {
        reg_bank[sym->regno].symbols = temp->next;
        delete temp;
        return;
    }
    symtab *prev = NULL;
    while (temp != NULL)
    {
        if (temp->head == sym)
        {
            prev->next = temp->next;
            delete temp;
            return;
        }
        prev = temp;
        temp = temp->next;
    }
}

void add_symbol(int reg, symbol *sym)
{
    symtab *temp = reg_bank[reg].symbols;
    if (sym->regno != -1)
    {
        remove_symbol(sym);
    }

    if (temp == NULL)
    {
        symtab *tempo = new symtab;
        tempo->head = sym;
        tempo->next = NULL;
        reg_bank[reg].symbols = tempo;
        sym->regno = reg;
        return;
    }

    if (temp->head == sym)
    {
        return;
    }

    while (temp->next != NULL)
    {
        temp = temp->next;
        if (temp->head == sym)
        {
            return;
        }
    }

    symtab *tempo = new symtab;
    tempo->head = sym;
    tempo->next = NULL;
    temp->next = tempo;
    sym->regno = reg;
}

int min_score()
{
    int min_score = 10000000;
    int in_mem = 0, in_temp = 0;
    int ret_val = -1;
    for (int i = 1; i <= reg_nos; i++)
    {
        symtab *temp = reg_bank[i].symbols;
        while (temp != NULL)
        {
            if (!temp->head->is_mem)
                in_mem++;
            if (temp->head->is_temp)
                in_temp++;
            temp = temp->next;
        }
        if (in_mem + 2 * in_temp < min_score)
        {
            min_score = in_mem + 2 * in_temp;
            ret_val = i;
        }
    }
    return ret_val;
}
int get_reg(symbol *sym, int is_res)
{
    if (sym->regno != -1)
    {
        if (reg_bank[sym->regno].symbols->next == NULL || is_res == 0)
        {
            if (is_res == 1)
            {
                sym->is_mem = 0;
            }
            return sym->regno;
        }
    }
    for (int i = 1; i <= reg_nos; i++)
    {
        if (reg_bank[i].symbols == NULL)
        {
            if (is_res == 1)
            {
                sym->is_mem = 0;
            }
            else
            {
                string tmp = "R" + to_string(i);
                emit("LD", sym->name, "", tmp, 1);
            }
            add_symbol(i, sym);
            return i;
        }
    }
    int min_reg = min_score();
    spill(min_reg, 1);
    if (is_res == 1)
    {
        sym->is_mem = 0;
    }
    else
    {
        string tmp = "R" + to_string(min_reg);
        emit("LD", sym->name, "", tmp, 1);
    }
    add_symbol(min_reg, sym);
    return min_reg;
}

string get_name(const string &name)
{
    symbol *sym = symbol_search(name, 0, 0);
    if (sym->is_const)
    {
        return sym->name;
    }
    int regallot = get_reg(sym, 0);
    return "R" + to_string(regallot);
}

// enums and functions to handle relational operations
enum Operation
{
    EQUAL,
    NOTEQUAL,
    LESS_THAN,
    GREATER_THAN,
    LESS_THAN_EQUAL,
    GREATER_THAN_EQUAL,
    UNKNOWN_OP
};

Operation get_operation_enum(const string &op)
{
    if (op == "=")
        return EQUAL;
    if (op == "!=")
        return NOTEQUAL;
    if (op == "<")
        return LESS_THAN;
    if (op == ">")
        return GREATER_THAN;
    if (op == "<=")
        return LESS_THAN_EQUAL;
    if (op == ">=")
        return GREATER_THAN_EQUAL;
    return UNKNOWN_OP;
}

string get_operation_string(Operation op)
{
    switch (op)
    {
    case EQUAL:
        return "JNE";
    case NOTEQUAL:
        return "JEQ";
    case LESS_THAN:
        return "JGE";
    case GREATER_THAN:
        return "JLE";
    case LESS_THAN_EQUAL:
        return "JGT";
    case GREATER_THAN_EQUAL:
        return "JLT";
    default:
        return "";
    }
}

// enums and functions to handle arithmetic operations
enum ArithmeticOperation
{
    ADD,
    SUB,
    MUL,
    DIV,
    MOD,
    UNKNOWN_ARITHMETIC_OP
};

ArithmeticOperation get_arithmetic_operation_enum(const string &op)
{
    if (op == "+")
        return ADD;
    if (op == "-")
        return SUB;
    if (op == "*")
        return MUL;
    if (op == "/")
        return DIV;
    if (op == "%")
        return MOD;
    return UNKNOWN_ARITHMETIC_OP;
}

string get_arithmetic_operation_string(ArithmeticOperation op)
{
    switch (op)
    {
    case ADD:
        return "ADD";
    case SUB:
        return "SUB";
    case MUL:
        return "MUL";
    case DIV:
        return "DIV";
    case MOD:
        return "MOD";
    default:
        return "";
    }
}

void generateTargetCode()
{
    int block = 1;
    for (int i = 1; i < next_instr; i++)
    {
        quads[i].alt_ins = ass_instr;

        if (quads[i].op == "=")
        {
            symbol *arg1 = symbol_search(quads[i].arg1, 0, 0);
            symbol *result = symbol_search(quads[i].result, 0, 0);
            if (arg1->is_const)
            {
                int result_reg = get_reg(result, 1);
                string tmp = "R" + to_string(result_reg);
                emit("LDI", quads[i].arg1, "", tmp, 1);
            }
            else
            {
                int arg_reg = get_reg(arg1, 0);
                add_symbol(arg_reg, result);
                result->is_mem = 0;
            }

            if (leaders[i + 1] != 0)
            {
                for (int i = 1; i < reg_nos + 1; i++)
                {
                    spill(i, 0);
                }
            }
        }
        else if (quads[i].op == "gt")
        {
            for (int i = 1; i < reg_nos + 1; i++)
            {
                spill(i, 0);
            }
            emit("JMP", "", "", quads[i].result, 1);
        }
        else if (quads[i].op == "if")
        {
            string arg1, operation, arg2;
            istringstream iss(quads[i].arg1);
            iss >> arg1 >> operation >> arg2;
            string arg1_name = get_name(arg1);
            string arg2_name = get_name(arg2);

            for (int i = 1; i < reg_nos + 1; i++)
            {
                spill(i, 0);
            }

            Operation op = get_operation_enum(operation);
            string opr = get_operation_string(op);

            emit(opr, arg1_name, arg2_name, quads[i].result, 1);
        }
        else
        {
            string arg1_name = get_name(quads[i].arg1);
            string arg2_name = get_name(quads[i].arg2);

            symbol *result = symbol_search(quads[i].result, 1, 0);
            int result_reg = get_reg(result, 1);
            string result_name = "R" + to_string(result_reg);

            string operation = quads[i].op;

            ArithmeticOperation op = get_arithmetic_operation_enum(operation);
            string opr = get_arithmetic_operation_string(op);

            emit(opr, arg1_name, arg2_name, result_name, 1);

            if (leaders[i + 1] != 0)
            {
                for (int i = 1; i < reg_nos + 1; i++)
                {
                    spill(i, 0);
                }
            }
        }
        quad_cnt++;
    }
}

void printAssembly()
{
    int block = 1;
    int lastIns = 0;
    for (int i = 1; i < ass_instr; i++)
    {
        if (lastIns != quads2[i].alt_ins)
        {
            lastIns = quads2[i].alt_ins;
            if (leaders[lastIns] == 1)
            {
                if (i != 1)
                {
                    cout << "\n";
                }
                cout << "Block " << block++ << endl;
            }
        }
        cout << "  ";
        if (quads2[i].op[0] == 'J')
        {
            int jmp = atoi(quads2[i].result.c_str());
            jmp = quads[jmp].alt_ins;
            jmp = (jmp == 0) ? ass_instr : jmp;
            quads2[i].result = jmp;
            if (quads2[i].arg2 == "")
            {
                if (quads2[i].arg1 == "")
                {
                    cout << i << "\t: " << quads2[i].op << " " << jmp << "\n";
                }
                else
                {
                    cout << i << "\t: " << quads2[i].op << " " << quads2[i].arg1 << " " << jmp << "\n";
                }
            }
            else
            {
                cout << i << "\t: " << quads2[i].op << " " << quads2[i].arg1 << " " << quads2[i].arg2 << " " << jmp << "\n";
            }
        }
        else
        {
            cout << i << "\t: " << quads2[i].op << " " << quads2[i].result << " " << quads2[i].arg1 << " " << quads2[i].arg2 << " " << "\n";
        }
    }
    cout << "\n"
         << "  " << ass_instr << "\t:";
}

int main(int argc, char const *argv[])
{
    reg_nos = 5;
    SymbolTable = NULL;
    temp_count = 1;
    ass_instr = 1;
    quad_cnt = 1;
    next_instr = 1;

    ofstream file1("intermediate_code.txt");
    streambuf *old_buf = cout.rdbuf(file1.rdbuf());
    cout << "---------- Blocks of Intermediate Code ----------\n";
    for (int i = 0; i < 1000; i++)
    {
        leaders[i] = 0;
    }
    leaders[1] = 1;
    yyparse();
    for (int i = 1; i < 1000; i++)
    {
        size_t pos = quads[i].arg1.find("/=");
        if (pos != string::npos)
        {
            quads[i].arg1.replace(pos, 2, "!=");
        }
    }
    print_quads();
    cout.rdbuf(old_buf);
    file1.close();

    ofstream file2("target_code.txt");
    old_buf = cout.rdbuf(file2.rdbuf());
    cout << "---------- Target Code ----------\n";
    generateTargetCode();
    printAssembly();
    return 0;
}

void yyerror(string s)
{
    cout << s << endl;
}