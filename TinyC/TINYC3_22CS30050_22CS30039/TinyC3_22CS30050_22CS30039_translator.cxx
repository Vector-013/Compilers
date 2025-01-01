#include "TinyC3_22CS30050_22CS30039_translator.h"

void initializeContext()
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    globalContext.currentSymbol = nullptr;
    globalContext.globalST = new SymbolTable("Global");
    globalContext.STCount = 0;
    globalContext.blockName = "Global";
    globalContext.currentST = globalContext.globalST;
}

// Helper function to print the header
void printHeader(const std::string &tableName, const std::string &parentName)
{
    const int tableWidth = 150;
    const int labelWidth = 50;
    const int centerPadding = (tableWidth - labelWidth * 2) / 2;

    std::cout << std::setfill('=') << std::setw(tableWidth) << "=" << std::endl; // Print a line of '='
    std::cout << std::setfill(' ') << std::setw(centerPadding) << " "
              << "[SYMBOL TABLE]: " << std::setw(labelWidth) << std::left << tableName // Print the table name
              << "[PARENT]: " << std::setw(labelWidth) << parentName
              << std::endl; // Print the parent name

    std::cout << std::string(tableWidth, '=') << std::endl;
}

void printFormatted(const std::string &text, int width, char fillChar = ' ')
{
    std::cout << std::setfill(fillChar) << std::setw(width) << text;
}

void printTableHeader() // Helper function to print the table header
{
    printFormatted("Name", 15);
    std::cout << "|\t";
    printFormatted("Type", 25);
    std::cout << "|\t";
    printFormatted("Initial Value", 20);
    std::cout << "|\t";
    printFormatted("Size", 15);
    std::cout << "|\t";
    printFormatted("Offset", 15);
    std::cout << "|\t";
    std::cout << "Nested" << std::endl;

    std::cout << std::string(150, '-') << std::endl;
}

void printSymbolEntry(const Term &term) // Helper function to print the symbol entry
{
    printFormatted(term.name, 15);
    std::cout << "|\t";
    printFormatted(checkType(term.type), 25);
    std::cout << "|\t";
    printFormatted(term.value.empty() ? "-" : term.value, 20);
    std::cout << "|\t";
    printFormatted(std::to_string(term.size), 15);
    std::cout << "|\t";
    printFormatted(std::to_string(term.offset), 15);
    std::cout << "|\t" << std::endl;
}

// Main print function for the SymbolTable
void SymbolTable::print()
{
    std::string parentName = (this->parent) ? this->parent->name : "NN";
    printHeader(this->name, parentName);
    printTableHeader();

    std::list<SymbolTable *> nests;

    // Print the symbols in the symbol table
    for (const auto &it : this->table)
    {
        printSymbolEntry(it);

        // Print the name of the nested symbol table
        if (it.nestedTable)
        {
            std::cout << it.nestedTable->name << std::endl;
            nests.push_back(it.nestedTable);
        }
        else
        {
            std::cout << "NULL" << std::endl;
        }
    }

    std::cout << std::string(150, '=') << std::endl
              << std::endl;

    // Recursively print nested symbol tables
    for (auto &nested : nests)
    {
        nested->print();
    }
}

// Lookup for a symbol in the symbol table
Term *SymbolTable::lookup(std::string name)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    // Iterate through the symbol table
    for (auto &symbol : this->table)
    {
        if (name == symbol.name)
        {
            return &symbol; // Return a reference to the found symbol
        }
    }

    // If not found in the current symbol table, look in the parent symbol table
    if (this->parent)
    {
        Term *parentLookup = this->parent->lookup(name);
        if (parentLookup)
        {
            return parentLookup; // Return found symbol from parent
        }
    }
    // If the symbol is not found in the parent symbol table and globalContext.currentST is this
    if (globalContext.currentST == this)
    {
        this->table.emplace_back(name, "int"); // Construct a new Term in place
        return &this->table.back();            // Return reference to the newly created Term
    }

    return nullptr;
}

// Update the symbol type and size
Term *Term::update(TType *t)
{
    this->type = t;
    this->size = sizeOfType(t);
    return this;
}

void SymbolTable::update() // Update the symbol table
{
    std::list<SymbolTable *> nests;
    int total_offset = 0;

    // Update the offsets of the symbols based on their sizes
    for (auto &symbol : this->table)
    {
        symbol.offset = total_offset;
        total_offset += symbol.size;

        if (symbol.nestedTable)
        {
            nests.push_back(symbol.nestedTable);
        }
    }

    // Update the nested symbol tables
    for (auto *nested : nests)
    {
        nested->update();
    }
}

// Generate a new temporary variable
Term *SymbolTable::genTemp(TType *t, std::string initializer)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    // Generate a new temporary variable name
    std::string name = "t" + std::to_string(globalContext.currentST->tempCount++);

    // Add the symbol to the symbol table
    globalContext.currentST->table.emplace_back(name, "int", t, initializer, sizeOfType(t));

    // Return the pointer to the symbol
    return &(globalContext.currentST->table.back());
}

void Quad::print() // Print the quad
{
    std::string output; // formatting each string based upon different cases
    if (op == "call")
    {
        output = result + " = call " + arg1 + ", " + arg2;
    }
    else if (op == "label")
    {
        output = result + ": ";
    }
    else if (op == "goto" || op == "param" || op == "return")
    {
        output = op + " " + result;
    }
    else if (op == "[]=")
    {
        output = result + "[" + arg1 + "] = " + arg2;
    }
    else if (op == "=[]")
    {
        output = result + " = " + arg1 + "[" + arg2 + "]";
    }
    else if (op == "*=")
    {
        output = "*" + result + " = " + arg1;
    }
    else if (op == "=")
    {
        output = result + " = " + arg1;
    }
    else if (op == "+" || op == "-" || op == "*" || op == "/" || op == "%" ||
             op == "^" || op == "|" || op == "&" || op == "<<" || op == ">>")
    {
        output = result + " = " + arg1 + " " + op + " " + arg2;
    }
    else if (op == "==" || op == "!=" || op == "<" || op == ">" ||
             op == "<=" || op == ">=")
    {
        output = "if " + arg1 + " " + op + " " + arg2 + " goto " + result;
    }
    else if (op == "= &" || op == "= *" || op == "= -" || op == "= ~" || op == "= !")
    {
        output = result + " " + op + arg1;
    }
    else
    {
        output = "Unknown Operator";
    }
    std::cout << output;
}
void QuadArray::print() // Print the quad array
{
    std::cout << "THREE ADDRESS CODE (TAC):" << std::endl;

    int cnt = 0;
    // Print each of the quads one by one
    for (auto &quad : this->quads)
    {
        // Print a newline if the operation is a label
        std::cout << (quad.op == "label" ? "\n" : "");
        std::cout << std::left << std::setw(4) << cnt++ << ": ";
        quad.print();
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

// Creates a list containing a single integer element
std::list<int> makeList(int item)
{
    return {item};
}

// Merges two lists and returns the result
std::list<int> merge(std::list<int> &list1, std::list<int> &list2)
{
    list1.splice(list1.end(), list2); // Splice for efficient merge without copying
    return list1;
}

// Checks if the given symbol types are the same
bool typecheck(TType *t1, TType *t2)
{
    // Return true if both types are NULL, false if only one is NULL
    if (t1 == nullptr || t2 == nullptr)
        return t1 == t2;

    // Return false if the primary types differ; otherwise, check array types recursively
    return (t1->type == t2->type) && typecheck(t1->arrType, t2->arrType);
}

// Backpatches the quad list at the specified indices with the given integer as a string
void backpatch(std::list<int> indices, int value)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    // Convert the integer to a std::string
    std::string valueStr = std::to_string(value);

    // Update the result of the quads at the specified indices
    for (int index : indices)
    {
        globalContext.quadList.quads[index].result = valueStr;
    }
}

// Determines the size in bytes of the specified type
int sizeOfType(TType *type)
{
    if (!type)
        return -1; // Invalid type

    if (type->type == "void")
        return SIZE_VOID;
    if (type->type == "char")
        return SIZE_CHAR;
    if (type->type == "int" || type->type == "ptr")
        return SIZE_INT;
    if (type->type == "float")
        return SIZE_FLOAT;
    if (type->type == "arr")
        return type->width * sizeOfType(type->arrType);
    if (type->type == "func")
        return SIZE_VOID; // Functions have no size

    return -1; // Unknown type
}
// Helper function to convert type string to an integer identifier

// Changes the current symbol table
void changeTable(SymbolTable *newTable)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    globalContext.currentST = newTable;
}

// Returns the index of the next instruction to be emitted
int nextInstruction()
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    return static_cast<int>(globalContext.quadList.quads.size()); // always return int type
}

// Creates a new quad and adds it to the quad list
void emit(std::string op, std::string result, std::string arg1, std::string arg2)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    globalContext.quadList.quads.emplace_back(result, arg1, op, arg2);
}

// Creates a new quad and adds it to the quad list
void emit(std::string op, std::string result, int arg1, std::string arg2)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    globalContext.quadList.quads.emplace_back(result, std::to_string(arg1), op, arg2);
}

// Creates a new quad and adds it to the quad list
void emit(std::string op, std::string result, float arg1, std::string arg2)
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    globalContext.quadList.quads.emplace_back(result, std::to_string(arg1), op, arg2);
}

// Converts the type of the symbol `s` to the specified type `targetType` if necessary
Term *convertType(Term *s, std::string targetType)
{
    // Generate a temporary symbol with the target type
    Term *temp = SymbolTable::genTemp(new TType(targetType));

    // Helper lambda to handle the conversion emission and return the temporary symbol
    auto emitConversion = [&](const std::string &conversionMessage) -> Term *
    {
        emit("=", temp->name, conversionMessage + "(" + s->name + ")");
        return temp;
    };

    // Check current symbol type and convert if it differs from target type
    const std::string &sourceType = s->type->type;

    if (sourceType == "float")
    {
        if (targetType == "int")
            return emitConversion("convertFloatToInt");
        if (targetType == "char")
            return emitConversion("convertFloatToChar");
    }
    else if (sourceType == "int")
    {
        if (targetType == "float")
            return emitConversion("convertIntToFloat");
        if (targetType == "char")
            return emitConversion("convertIntToChar");
    }
    else if (sourceType == "char")
    {
        if (targetType == "float")
            return emitConversion("convertCharToFloat");
        if (targetType == "int")
            return emitConversion("convertCharToInt");
    }

    // Return original symbol if no conversion is needed
    return s;
}

// Helper function to attempt type conversion
bool attemptTypeConversion(Term *&symbol, const std::string &targetType)
{
    symbol = convertType(symbol, targetType);
    return symbol != nullptr;
}

// Checks if the types of the given symbols are compatible
bool typecheck(Term *&symbol1, Term *&symbol2)
{
    TType *type1 = symbol1->type;
    TType *type2 = symbol2->type;

    // Direct type match check
    if (typecheck(type1, type2))
        return true;

    // Attempt type conversion for compatibility
    if (attemptTypeConversion(symbol1, type2->type) || attemptTypeConversion(symbol2, type1->type))
        return true;

    return false;
}

// Helper function for emitting a comparison operation
void emitComparison(const std::string &varName, const std::string &value)
{
    emit("==", varName, value);
}

// Helper function for emitting an unconditional goto statement
void emitGoto(const std::string &target = "")
{
    emit("goto", target);
}

// Helper function for emitting an assignment operation
void emitAssignment(const std::string &target, const std::string &value)
{
    emit("=", target, value);
}

// Converts an integer-type expression to a boolean-type expression
Expression *boolMaker(Expression *expr)
{
    if (expr->type != "bool")
    {
        // Prepare lists for true and false branching
        expr->falseList = makeList(nextInstruction());
        emitComparison(expr->loc->name, "0"); // Emit comparison for false case

        expr->trueList = makeList(nextInstruction());
        emitGoto(); // Emit unconditional goto for true case
    }
    return expr;
}

void drawTable()
{
    GlobalContext &globalContext = GlobalContext::getInstance();
    globalContext.globalST->update();
    globalContext.quadList.print();
    globalContext.globalST->print();
}

// Converts a boolean-type expression to an integer-type expression
Expression *intMaker(Expression *expr)
{
    if (expr->type != "bool")
    {
        return expr; // Return early if the expression type is not boolean
    }

    // Assign a new temporary variable of integer type
    expr->loc = SymbolTable::genTemp(new TType("int"));

    // Backpatch true/false lists and emit instructions for assignment
    backpatch(expr->trueList, nextInstruction());
    emitAssignment(expr->loc->name, "1"); // Use 1 to represent true

    emitGoto(std::to_string(nextInstruction() + 1)); // Jump to end after setting true
    backpatch(expr->falseList, nextInstruction());
    emitAssignment(expr->loc->name, "0"); // Use 0 to represent false

    return expr;
}

// Checks the type of the given TType
std::string checkType(TType *type)
{
    if (type == nullptr)
        return "null"; // Return "null" for null type pointer

    // Check for basic types and return directly
    const std::array<std::string, 6> basicTypes = {"void", "char", "int", "float", "block", "func"};
    for (const auto &basicType : basicTypes)
    {
        if (type->type == basicType)
        {
            return type->type; // Return basic type
        }
    }

    // Handle pointer types
    if (type->type == "ptr")
    {
        return "ptr(" + checkType(type->arrType) + ")";
    }

    // Handle array types
    if (type->type == "arr")
    {
        return "arr(" + std::to_string(type->width) + ", " + checkType(type->arrType) + ")";
    }

    // If type doesn't match any known types, return "Unknown Type"
    return "Unknown Type";
}

int main()
{
    initializeContext();
    yyparse();
    std::cout << "Parsing completed successfully!" << std::endl;
    drawTable();
}
