#ifndef _TRANSLATOR_H
#define _TRANSLATOR_H

#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <functional>
#include <iomanip>
#include <string.h>

#define SIZE_VOID 0
#define SIZE_CHAR 1
#define SIZE_INT 4
#define SIZE_PTR 4
#define SIZE_FLOAT 8

class Term;
class TType;
class SymbolTable;
class Quad;
class QuadArray;

extern char *yytext;
extern int yyparse();

class TType
{
public:
    std::string type; // The type of the symbol (e.g., int, float, char)
    int width;        // The size of the type in bytes
    TType *arrType;   // Pointer to the array type, if applicable

    // Constructor to initialize the TType object
    // Parameters:
    // - type1: The type as a string (e.g., "int", "float")
    // - arrType1: Pointer to the array type (default is nullptr)
    // - width1: The width of the type (default is 1)
    TType(std::string type1, TType *arrType1 = nullptr, int width1 = 1)
        : type(type1), width(width1), arrType(arrType1) {}
};
// Get the size of a specified type.
int sizeOfType(TType *t);

class Term
{
    /*
     * Term class represents a symbol in the symbol table.
     * It contains the name, type, value, size, offset, and nested table of the symbol.
     * The type is represented by a TType object.
     * The value is the initial value of the symbol.
     */
public:
    std::string name;
    TType *type;
    std::string value;
    int size;
    int offset;
    SymbolTable *nestedTable;

    Term(std::string name1, std::string t, TType *arrType = nullptr, int width = 0)
        : name(name1), value("-"), offset(0), nestedTable(nullptr)
    {
        this->type = new TType(t, arrType, width);
        this->size = sizeOfType(type);
    }

    Term(std::string name1, std::string t, TType *arrType, const std::string &initializer, int width)
        : name(name1), type(arrType), value(initializer), size(width), offset(0), nestedTable(nullptr) {}

    Term *update(TType *t);
};

class SymbolTable
{
public:
    std::string name = "NULL"; // Name of the symbol table (e.g., "Global", "Function")
    int tempCount;             // Counter for temporary variables
    std::list<Term> table;     // List of terms (symbols) in the symbol table
    SymbolTable *parent;       // Pointer to the parent symbol table (for nested scopes)

    // Constructor to initialize a SymbolTable with a given name and initialize tempCount to 0.
    SymbolTable(std::string name1) : name(name1), tempCount(0) {}

    // Lookup a term by its name in the symbol table and return a pointer to the Term object.
    Term *lookup(std::string name);

    // Generate a temporary term of the specified type, optionally initialized to a given value.
    static Term *genTemp(TType *t, std::string initValue = "");

    // Print the contents of the symbol table (for debugging purposes).
    void print();

    // Update the symbol table (may be used to refresh or finalize symbol entries).
    void update();
};

class Quad
{
public:
    std::string op;     // The operation (e.g., "+", "-", "=", etc.)
    std::string arg1;   // The first argument of the operation
    std::string arg2;   // The second argument of the operation (optional)
    std::string result; // The result of the operation

    // Constructor with string arguments to initialize a Quad with specified result, first argument, operation, and optional second argument.
    Quad(std::string resName, std::string firstArg, std::string operation = "=", std::string secondArg = "")
        : result(resName), arg1(firstArg), op(operation), arg2(secondArg) {}

    // Constructor with integer argument to initialize a Quad. Converts the integer to a string for the first argument.
    Quad(std::string resName, int firstArg, std::string operation = "=", std::string secondArg = "")
        : result(resName), op(operation), arg2(secondArg)
    {
        arg1 = std::to_string(firstArg); // Convert integer to string
    }

    // Constructor with float argument to initialize a Quad. Converts the float to a string for the first argument.
    Quad(std::string resName, float firstArg, std::string operation = "=", std::string secondArg = "")
        : result(resName), op(operation), arg2(secondArg)
    {
        arg1 = std::to_string(firstArg); // Convert float to string
    }

    // Print the Quad object details (for debugging or output purposes).
    void print();
};

class QuadArray
{
public:
    std::vector<Quad> quads; // Vector of quads

    void print();       // Print the quad array
};

class Array
{
public:
    std::string atype; // Type of the array (e.g., "arr" for array, "ptr" for pointer)
    Term *loc;         // Pointer to the term that represents the location of the array
    Term *Array;       // Pointer to the term representing the array itself
    TType *type;       // Pointer to the type of the array elements
};

class Statement
{
public:
    std::list<int> nextList; // List of instruction numbers to be executed next (for control flow)
};

class Expression
{
public:
    std::string type;         // Type of the expression (e.g., "int", "bool", etc.)
    Term *loc;                // Pointer to the term representing the location of the expression's value
    std::list<int> trueList;  // List of instruction numbers for the true branch of a conditional
    std::list<int> falseList; // List of instruction numbers for the false branch of a conditional
    std::list<int> nextList;  // List of instruction numbers for the next statements to execute
};

class GlobalContext
{
private:
    // Private constructor to prevent instantiation
    GlobalContext() : currentSymbol(nullptr), currentST(nullptr), globalST(nullptr), STCount(0) {}

    // Private destructor
    ~GlobalContext() {}

    // Copy constructor and assignment operator are deleted to prevent copying
    GlobalContext(const GlobalContext &) = delete;
    GlobalContext &operator=(const GlobalContext &) = delete;

public:
    // Public variables
    Term *currentSymbol;    // Pointer to the current symbol
    SymbolTable *currentST; // Pointer to the current symbol table
    SymbolTable *globalST;  // Pointer to the global symbol table
    QuadArray quadList;     // List of quads
    int STCount;            // Count of the symbol tables
    std::string blockName;  // Name of the current block
    std::string varType;    // Type of the current variable

    // Static method to access the single instance of the class
    static GlobalContext &getInstance()
    {
        static GlobalContext instance; // Guaranteed to be destroyed
        return instance;               // Instantiated on first use
    }
};

extern GlobalContext globalContext;

// Emit a code instruction with two operands (can be either string, int, or float).
void emit(std::string op, std::string result, std::string arg1 = "", std::string arg2 = "");

// Emit a code instruction with an integer operand.
void emit(std::string op, std::string result, int arg1, std::string arg2 = "");

// Emit a code instruction with a float operand.
void emit(std::string op, std::string result, float arg1, std::string arg2 = "");

// Create a new list containing a single integer element.
std::list<int> makeList(int i);

// Merge two lists of integers and return the merged list.
std::list<int> merge(std::list<int> &p1, std::list<int> &p2);

// Backpatch a list of instruction addresses with a new address.
void backpatch(std::list<int> l, int address);

// Check if the types of two Term objects are compatible.
bool typecheck(Term *&s1, Term *&s2);

// Check if the types of two TType objects are the same.
bool typecheck(TType *t1, TType *t2);

// Convert the type of a Term object to the specified type.
Term *convertType(Term *s, std::string t);

// Create a boolean representation from an Expression object.
Expression *boolMaker(Expression *expr);

// Convert a boolean Expression to an integer Expression.
Expression *intMaker(Expression *expr);

// Change the current symbol table to the specified new table.
void changeTable(SymbolTable *newTable);

// Get the next instruction number in the instruction list.
int nextInstruction();

// Check the type of a TType object and return a string representation.
std::string checkType(TType *t);

#endif