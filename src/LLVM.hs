module Main where

import AbsInstant
import LexInstant
import ParInstant
import ErrM
import qualified Data.Map.Lazy as Map

type Store = Map.Map Ident Integer  

generate :: [Stmt] -> Store -> Integer -> [String] -> [String]
generate (x:s) store n llvm = llvm ++ generate s new_store new_n new_lines
    where (new_n, new_store, new_lines) = exec x store n
generate _ store n llvm = llvm  

exec :: Stmt -> Store -> Integer -> (Integer, Store, [String])
exec (SAss x exp) s n = (new_n, (Map.insert x new_n s), new_lines)
    where (new_n, new_lines) = eval exp s n
exec (SExp exp) s n = (new_n, s, new_lines ++ ["    call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], " ++
    "[4 x i8]* @.str, i32 0, i32 0), i32 %t" ++ show new_n ++ ")"]) 
    where (new_n, new_lines) = eval exp s n

eval :: Exp -> Store -> Integer -> (Integer, [String])
eval exp s n = case exp of
    ExpAdd exp0 exp -> binoperator exp0 exp s n "add"
    ExpMul exp0 exp -> binoperator exp0 exp s n "mul"
    ExpSub exp0 exp -> binoperator exp0 exp s n "sub"
    ExpDiv exp0 exp -> binoperator exp0 exp s n "udiv"
    ExpLit const -> (n+1, ["    %t" ++ show (n+1) ++ " = add i32 " ++ show const ++ ", 0"])
    ExpVar x -> (n+1, ["    %t" ++ show (n+1) ++ " = add i32 %t" ++ show number ++ ", 0"])
        where Just number = Map.lookup x s

binoperator exp0 exp s n operator = (n2+1, s1 ++ s2 ++ ["    %t" ++ show (n2+1) ++ " = " ++ operator ++ " i32 %t" ++ show n1 ++ ", %t" ++ show n2]) 
    where 
        (n1, s1) = eval exp0 s n
        (n2, s2) = eval exp s n1

gen s = let Ok (Prog e) = pProgram (myLexer s) 
    in generate e Map.empty 0 []

joinAll rest = ["declare i32 @printf(i8*, ...)",
        "@.str = private unnamed_addr constant [4 x i8] c\"%d\\0A\\00\", align 1",
        "define i32 @main() {" ] ++ rest ++ ["    ret i32 0", "}"]

main = do
    contents <- getContents
    mapM_ putStrLn (joinAll (gen contents))