type expr =
  | Word of string
  | String_expr of string
  | Int_expr of int
  | Add_expr of expr * expr
  | Sub_expr of expr * expr
  | Mul_expr of expr * expr
  | Div_expr of expr * expr
  | Mod_expr of expr * expr
  | Equal_expr of expr * expr
  | LessThan_expr of expr * expr
  | Negation_expr of expr

type sentence = Old of string * expr list | New of string * expr
type program = sentence list

exception ErrorParsingVariadicNamedArgs

let parse_variadic_named_args args =
  let rec parse_variadic_named_args' = function
    | Word name :: arg :: rest -> (name, arg) :: parse_variadic_named_args' rest
    | [] -> []
    | _ -> raise ErrorParsingVariadicNamedArgs
  in
  let pairs = parse_variadic_named_args' args in
  List.fold_left
    (fun acc (k, v) ->
      Hashtbl.add acc k v;
      acc)
    (Hashtbl.create @@ List.length pairs)
    pairs
