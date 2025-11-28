open State
open Ast

exception TypeError of string

let data_by_name state name =
  if String.starts_with ~prefix:"EXT_" name then
    Some
      (Extern_var.extern_var state (String.sub name 4 (String.length name - 4)))
  else State.data_by_name state name

let rec printable (expr : expr) =
  match expr with
  | Word x -> x
  | String_expr x -> x
  | Int_expr x -> Int.to_string x
  | Add_expr (a, b) -> "(" ^ printable a ^ ") + (" ^ printable b ^ ")"
  | Sub_expr (a, b) -> "(" ^ printable a ^ ") - (" ^ printable b ^ ")"
  | Mul_expr (a, b) -> "(" ^ printable a ^ ") * (" ^ printable b ^ ")"
  | Div_expr (a, b) -> "(" ^ printable a ^ ") / (" ^ printable b ^ ")"
  | Mod_expr (a, b) -> "(" ^ printable a ^ ") ** (" ^ printable b ^ ")"
  | Negation_expr e -> "(! " ^ printable e ^ ")"
  | LessThan_expr (a, b) -> "(" ^ printable a ^ ") < (" ^ printable b ^ ")"
  | Equal_expr (a, b) -> "(" ^ printable a ^ ") == (" ^ printable b ^ ")"

let expr_add a b =
  match (a, b) with
  | Int_value a, Int_value b -> Int_value (a + b)
  | _ -> failwith "TODO expr_add"

let expr_sub a b =
  match (a, b) with
  | Int_value a, Int_value b -> Int_value (a - b)
  | _ -> failwith "TODO expr_sub"

let expr_mul a b =
  match (a, b) with
  | Int_value a, Int_value b -> Int_value (a * b)
  | _ -> failwith "TODO expr_mul"

let expr_div a b =
  match (a, b) with
  | Int_value a, Int_value b -> Int_value (a / b)
  | _ -> failwith "TODO expr_div"

let expr_mod a b =
  match (a, b) with
  | Int_value a, Int_value b -> Int_value (a mod b)
  | _ -> failwith "TODO expr_mod"

let expr_lessthan a b =
  match (a, b) with
  | Int_value a, Int_value b -> Bool_value (a < b)
  | _ -> failwith "TODO expr_lessthan"

let expr_equal a b =
  match (a, b) with
  | Int_value a, Int_value b -> Bool_value (a == b)
  | String_value a, String_value b -> Bool_value (a == b)
  | _ -> failwith "TODO expr_equal"

let expr_negation e =
  match e with
  | Bool_value b -> Bool_value (not b)
  | _ -> failwith "TODO expr_negation"

let rec eval state expr : value =
  let eval = eval state in
  match expr with
  | Word w -> (
      match String.uppercase_ascii w with
      | "TRUE" -> Bool_value true
      | "FALSE" -> Bool_value false
      | _ -> data_by_name state w |> Option.get)
  | String_expr s -> String_value s
  | Int_expr i -> Int_value i
  | Add_expr (a, b) -> expr_add (eval a) (eval b)
  | Sub_expr (a, b) -> expr_sub (eval a) (eval b)
  | Mul_expr (a, b) -> expr_mul (eval a) (eval b)
  | Div_expr (a, b) -> expr_div (eval a) (eval b)
  | Mod_expr (a, b) -> expr_mod (eval a) (eval b)
  | LessThan_expr (a, b) -> expr_lessthan (eval a) (eval b)
  | Equal_expr (a, b) -> expr_equal (eval a) (eval b)
  | Negation_expr e -> expr_negation (eval e)

let to_boolean (state : abap_state) (expr : expr) =
  match eval state expr with
  | Bool_value b -> b
  | Int_value i -> i > 0
  | String_value _ -> raise @@ TypeError "Expected bool, got int"

let to_int (state : abap_state) (expr : expr) =
  match eval state expr with
  | Bool_value b -> if b then 1 else 0
  | Int_value i -> i
  | String_value _ -> raise @@ TypeError "Expected int, got string"

let to_string (state : abap_state) (expr : expr) =
  match eval state expr with
  | Bool_value b -> Bool.to_string b
  | Int_value i -> Int.to_string i
  | String_value s -> s
