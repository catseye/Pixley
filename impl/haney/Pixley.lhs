> module Pixley where

> import Text.ParserCombinators.Parsec
> import qualified Data.Map as Map

Definitions
===========

An environment maps names (represented as strings) to expressions.

> type Env = Map.Map String Expr

> data Expr = Symbol String
>           | Cons Expr Expr
>           | Null
>           | Boolean Bool
>           | Lambda Env Expr Expr
>           | Macro Env Expr
>     deriving (Ord, Eq)

> instance Show Expr where
>     show (Symbol s)      = s
>     show e@(Cons _ _)    = "(" ++ (showl e)
>     show Null            = "()"
>     show (Boolean True)  = "#t"
>     show (Boolean False) = "#f"
>     show (Lambda env args body) = "(lambda " ++ (show args) ++ " " ++ (show body) ++ ")"
>     show (Macro env body) = "(macro " ++ (show body) ++ ")"

> showl Null = ")"
> showl (Cons a Null) = (show a) ++ ")"
> showl (Cons a b) = (show a) ++ " " ++ (showl b)
> showl other = ". " ++ (show other) ++ ")"

Parser
======

The overall grammar of the language is:

    Expr ::= symbol | "(" {Expr} ")"

A symbol is denoted by a string which may contain only alphanumeric
characters, hyphens, underscores, and question marks.

> symbol = do
>     c <- letter
>     cs <- many (alphaNum <|> char '-' <|> char '?' <|> char '_' <|> char '*')
>     return (Symbol (c:cs))

> list = do
>     string "("
>     e <- many expr
>     spaces
>     string ")"
>     return (consFromList e)

The top-level parsing function implements the overall grammar given above.
Note that we need to give the type of this parser here -- otherwise the
type inferencer freaks out for some reason.

> expr :: Parser Expr
> expr = do
>     spaces
>     r <- (symbol <|> list)
>     return r

A convenience function for parsing Pixley programs.

> pa program = parse expr "" program

A helper function to make Cons cells from Haskell lists.

> consFromList [] =
>     Null
> consFromList (x:xs) =
>     Cons x (consFromList xs)

Evaluator
=========

TODO: should we actually put symbols like car and cdr in initial
environment?  (what does scheme do?)

> car (Cons a b) = a
> cdr (Cons a b) = b

We need to check for properly-formed lists, because that's what
Scheme and Pixley do.

> listp Null = Boolean True
> listp (Cons a b) = listp b
> listp _ = Boolean False

TODO: barf if symbol not in env

> eval env (Symbol s) =
>     (Map.!) env s
> eval env (Cons (Symbol "quote") (Cons sexpr Null)) =
>     sexpr
> eval env (Cons (Symbol "car") (Cons sexpr Null)) =
>     car (eval env sexpr)
> eval env (Cons (Symbol "cdr") (Cons sexpr Null)) =
>     cdr (eval env sexpr)
> eval env (Cons (Symbol "cons") (Cons sexpr1 (Cons sexpr2 Null))) =
>     Cons (eval env sexpr1) (eval env sexpr2)
> eval env (Cons (Symbol "list?") (Cons sexpr Null)) =
>     listp (eval env sexpr)
> eval env (Cons (Symbol "equal?") (Cons sexpr1 (Cons sexpr2 Null))) =
>     Boolean ((eval env sexpr1) == (eval env sexpr2))
> eval env (Cons (Symbol "let*") (Cons bindings (Cons body Null))) =
>     eval (bindAll bindings env) body
> eval env (Cons (Symbol "cond") rest) =
>     checkAll env rest
> eval env (Cons (Symbol "lambda") (Cons args (Cons body Null))) =
>     Lambda env args body

> eval env (Cons fun actuals) =
>     case eval env fun of
>         Lambda closedEnv formals body ->
>             eval (bindArgs closedEnv formals actuals) body
>         Macro closedEnv body ->
>             let
>                 env' = Map.insert "arg" actuals closedEnv
>             in
>                 eval env' body
> eval env weirdThing =
>     error ("You can't evaluate a " ++ show weirdThing)

> checkAll env (Cons (Cons (Symbol "else") (Cons branch Null)) Null) =
>     eval env branch
> checkAll env (Cons (Cons test (Cons branch Null)) rest) =
>     case eval env test of
>         Boolean True ->
>             eval env branch
>         Boolean False ->
>             checkAll env rest

> bindAll Null env =
>     env
> bindAll (Cons binding rest) env =
>     bindAll rest (bind binding env)

> bind (Cons (Symbol sym) (Cons sexpr Null)) env =
>     Map.insert sym (eval env sexpr) env

> bindArgs env Null Null =
>     env
> bindArgs env (Cons (Symbol sym) formals) (Cons actual actuals) =
>     Map.insert sym (eval env actual) (bindArgs env formals actuals)

> consFromEnvList [] =
>     Null
> consFromEnvList ((k,v):rest) =
>     Cons (Cons (Symbol k) (Cons v Null)) (consFromEnvList rest)

> envFromCons Null =
>     Map.empty
> envFromCons (Cons (Cons (Symbol k) (Cons v Null)) rest) =
>     Map.insert k v (envFromCons rest)

Top-Level Driver
================

> runPixley program =
>     let
>         Right ast = parse expr "" program
>     in
>         show $ eval Map.empty ast
