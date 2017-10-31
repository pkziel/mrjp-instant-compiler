A program in the Instant language consists of a sequence of statements separated by semicolons.

There are two kinds of statements:

expression - prints its value on stdout,
assignment of the form variable = expression - assigns value of the expression to he variable in the LHS; doe snot print anything.
Expressions are built from integer literals, variables and arithmetic operators. Evaluation order within an expression is not predefined (you can choose whatever order suits you best)

BNFC syntax:

Prog. Program ::= [Stmt] ;
SAss. Stmt ::= Ident "=" Exp;
SExp. Stmt ::= Exp ;
separator Stmt ";" ;

ExpAdd.            Exp1   ::= Exp2 "+"  Exp1 ;
ExpSub.            Exp2   ::= Exp2 "-"  Exp3 ;
ExpMul.            Exp3   ::= Exp3 "*"  Exp4 ;
ExpDiv.            Exp3   ::= Exp3 "/"  Exp4 ;
ExpLit.            Exp4   ::= Integer ;
ExpVar.            Exp4   ::= Ident ;
coercions Exp 4;
Note:

addition binds to the right
addition and multiplication are commutative but not associative
Your task is to write a compiler from Instant to JVM and LLVM.

In this assignment, the generated code should execute all the operations specified in the input program. Hence it is not allowed to replace the expression 2+3 by constant 5, omitting assignments to unused variables, etc. Improving generated code will be a subject of later assignments.

The only allowed, indeed desirable improvement is choosing an evaluation order so as to minimize the needed JVM stack size. In any case needed stack size must be computed and declared. (clever solutions like .limit stack 1000 will not be appreciated). Similarly you should compute and declare the number of needed locals.
