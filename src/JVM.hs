module Main where

import AbsInstant
import LexInstant
import ParInstant
import ErrM
import System.Environment

type Store = [(Ident, Integer)]

generate :: [Stmt] -> Store -> [String] -> [String]
generate (x:s) store jvm = jvm ++ generate s store (exec x store)
generate _ store jvm = jvm

exec :: Stmt -> Store -> [String]
exec (SAss x exp) s = eval exp s ++
    if number >= 0 && number <= 3
        then ["    istore_" ++ show number]
        else ["    istore " ++ show number]
    where Just number = lookup x s
exec (SExp exp) s = eval exp s ++ ["    getstatic java/lang/System/out Ljava/io/PrintStream;", "    swap", "    invokevirtual java/io/PrintStream/println(I)V"]

eval :: Exp -> Store -> [String]
eval exp s = case exp of
    ExpAdd exp0 exp -> (swapBranchesIfNeeded exp0 exp s) ++ ["    iadd"]
    ExpMul exp0 exp -> (swapBranchesIfNeeded exp0 exp s) ++ ["    imul"]
    ExpDiv exp0 exp -> eval exp0 s ++ eval exp s ++ ["    idiv"]
    ExpSub exp0 exp -> eval exp0 s ++ eval exp s ++ ["    isub"]
    ExpLit n ->
        if n >= 0 && n <= 5
            then ["    iconst_" ++ show n]
            else if n == -1
                then ["    iconst_m" ++ show n]
                else if n >= -128 && n <= 127
                    then ["    bipush " ++ show n]
                    else if n >= -32768 && n <= 32767
                        then ["    sipush " ++ show n]
                        else ["    ldc " ++ show n]
    ExpVar x ->
        if number >= 0 && number <= 3
            then ["    iload_" ++ show number]
            else ["    iload " ++ show number]
        where Just number = lookup x s

swapBranchesIfNeeded exp0 exp s = if (depth exp0) > (depth exp)
    then eval exp0 s ++ eval exp s
    else eval exp s ++ eval exp0 s

depth :: Exp -> Int
depth (ExpLit _) = 1
depth (ExpVar _) = 1
depth (ExpAdd x1 x2) = if a > b
    then max a (b + 1)
    else max b (a + 1)
    where
        a = depth x1
        b = depth x2
depth (ExpMul x1 x2) = if a > b
    then max a (b + 1)
    else max b (a + 1)
    where
        a = depth x1
        b = depth x2
depth (ExpSub x1 x2) = max (depth x1) (depth x2 + 1)
depth (ExpDiv x1 x2) = max (depth x1) (depth x2 + 1)

locals :: [Stmt] -> Store -> Integer -> (Integer, Store)
locals (x:s) store i = case x of
    SAss x exp -> case lookup x store of
        Nothing -> locals s ((x, i) : store) (i+1)
        Just v -> locals s store i
    otherwise -> locals s store i
locals _ store i = (i, store)

checkStackSize :: [Stmt] -> Int -> Int
checkStackSize (x:s) i = case x of
    (SAss x exp) -> checkStackSize s (max i (depth exp))
    (SExp exp) -> checkStackSize s (max i (depth exp))
checkStackSize _ i = i

isPrint (x:s) = case x of
    (SAss x exp) -> isPrint s
    (SExp exp) -> 2
isPrint _ = 0

gen s = let Ok (Prog e) = pProgram (myLexer s)
    in generate e (snd (locals e [] 1)) []

stack s = let Ok (Prog e) = pProgram (myLexer s)
    in max (checkStackSize e 0) (isPrint e)

countLocals s = let Ok (Prog e) = pProgram (myLexer s)
    in max (fst (locals e [] 1)) 1

joinAll stack_size locals rest name = [".class public " ++ name,
        ".super java/lang/Object",
        "",
        ".method public <init>()V",
        "    aload_0",
        "    invokenonvirtual java/lang/Object/<init>()V",
        "    return",
        ".end method",
        "",
        ".method public static main([Ljava/lang/String;)V",
        "    .limit stack " ++ show stack_size,
        "    .limit locals " ++ show locals
        ] ++ rest ++ ["    return", ".end method"]

main = do
    name <- getArgs
    contents <- getContents
    mapM_ putStrLn (joinAll (stack contents) (countLocals contents) (gen contents) (head name))
