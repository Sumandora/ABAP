open State
open Ast
open Extern_fun

let find_endwhile state index =
  let rec find_matching_while' state index depth =
    match sentence_at state index with
    | Old ("WHILE", _) -> find_matching_while' state (index + 1) (depth + 1)
    | Old ("ENDWHILE", _) ->
        if depth == 0 then index
        else find_matching_while' state (index + 1) (depth - 1)
    | _ -> find_matching_while' state (index + 1) depth
  in
  find_matching_while' state (index + 1) 0

let find_beginwhile state index =
  let rec find_matching_while' state index depth =
    match sentence_at state index with
    | Old ("ENDWHILE", _) -> find_matching_while' state (index - 1) (depth - 1)
    | Old ("WHILE", [ v ]) ->
        if depth == 0 then (index, v)
        else find_matching_while' state (index - 1) (depth + 1)
    | _ -> find_matching_while' state (index - 1) depth
  in
  find_matching_while' state (index - 1) 0

let find_endif state index =
  let rec find_matching_if' state index depth =
    match sentence_at state index with
    | Old ("IF", _) -> find_matching_if' state (index + 1) (depth + 1)
    | Old ("ENDIF", _) ->
        if depth == 0 then index
        else find_matching_if' state (index + 1) (depth - 1)
    | _ -> find_matching_if' state (index + 1) depth
  in
  find_matching_if' state (index + 1) 0

let find_if_exit state index evaluated_expr =
  if evaluated_expr then index + 1
  else
    let rec find_matching_if' state index depth =
      match sentence_at state index with
      | Old ("IF", _) -> find_matching_if' state (index + 1) (depth + 1)
      | Old ("ELSE", _) when depth == 0 && not evaluated_expr -> index + 1
      | Old ("ENDIF", _) ->
          if depth == 0 then index
          else find_matching_if' state (index + 1) (depth - 1)
      | _ -> find_matching_if' state (index + 1) depth
    in
    find_matching_if' state (index + 1) 0

let rec take_until_end_of_func sentences index =
  let sentence = List.nth sentences index in
  match sentence with
  | Old ("FUNCTION", _) ->
      raise
      @@ Failure
           "Discovered function inside function. This is forbidden for now..."
  | Old ("ENDFUNCTION", _) -> []
  | _ -> sentence :: take_until_end_of_func sentences (index + 1)

let invoke_sentence (state : abap_state) =
  let sentence = List.nth_opt state.sentences state.current_sentence in
  match sentence with
  | None -> (state, true)
  | Some sentence ->
      ( (match sentence with
        | Old (statement, args) -> (
            match (String.uppercase_ascii statement, args) with
            | "REPORT", [ Word name ] ->
                print_endline @@ "Starting report: " ^ name;
                advance_sentence state
            | "WRITE", [ text ] ->
                print_endline @@ Expr.to_string state text;
                advance_sentence state
            | "IF", [ expr ] ->
                let evaluated_expression = Expr.to_boolean state expr in
                let ending =
                  find_if_exit state state.current_sentence evaluated_expression
                in
                jump_to state ending
            | "ELSE", [] ->
                let ending = find_endif state state.current_sentence in
                jump_to state ending
            | "ENDIF", [] -> advance_sentence state
            | "FUNCTION", [ Word name ] ->
                let func_begin = state.current_sentence + 1 in
                let sentences =
                  take_until_end_of_func state.sentences func_begin
                in
                Hashtbl.add state.functions name func_begin;
                jump_to state
                  (state.current_sentence + 1 (* FUNCTION *)
                 + List.length sentences (* contents *) + 1 (* ENDFUNCTION *))
            | "CALL", [ Word "FUNCTION"; Word name ] ->
                let func_begin = Hashtbl.find state.functions name in
                call_to state func_begin
            | "ENDFUNCTION", [] -> pop_stackframe state
            | "DATA", Word name :: args ->
                let args = parse_variadic_named_args args in
                (* TODO lowercase *)
                let value_expr = Hashtbl.find args "VALUE" in
                let value = Expr.eval state value_expr in

                (match Hashtbl.find_opt args "TYPE" with
                | Some (Word s) ->
                    if value_ident value <> s then
                      failwith ("Wrong type for " ^ name)
                    else ()
                | Some _ -> failwith "type ident is not a word"
                | _ -> ());

                advance_sentence @@ add_data state name value
            | "WHILE", [ v ] ->
                let b = Expr.to_boolean state v in
                if b then advance_sentence state
                else jump_to state (find_endwhile state state.current_sentence)
            | "ENDWHILE", [] ->
                let begin_idx, arg =
                  find_beginwhile state state.current_sentence
                in
                if Expr.to_boolean state arg then jump_to state begin_idx
                else advance_sentence state
            | "CALL", Word "EXTERN" :: Word f :: args ->
                let new_state = extern_call state f args in
                advance_sentence new_state
            | _ ->
                print_endline @@ "Couldn't invoke sentence: " ^ statement
                ^ List.fold_left
                    (fun acc elem -> acc ^ " " ^ Expr.printable elem)
                    "" args;
                advance_sentence state)
        | New (var, value) ->
            let value = Expr.eval state value in
            let prev = Expr.data_by_name state var in
            if Option.is_none prev then failwith @@ var ^ " is undefined";
            if value_ident (Option.get prev) != value_ident value then
              failwith "Data was redefined with different type";
            let new_state = update_data state var value in
            advance_sentence new_state),
        false )
