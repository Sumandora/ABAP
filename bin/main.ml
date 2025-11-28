open Abap
open State
open Batteries

let _ =
  let channel =
    if Array.length Sys.argv > 1 then In_channel.open_text Sys.argv.(1)
    else Stdlib.stdin
  in

  (* Skip first line if starts with shebang *)
  let first_line = In_channel.input_line channel in
  if
    first_line
    |> Option.map (fun s -> not @@ String.starts_with s "#!")
    |> Option.default true
  then In_channel.seek channel 0L;

  let lexbuf = Stdlib.Lexing.from_channel channel in
  try
    let result = Parser.main Lexer.token lexbuf in
    let state =
      ref
        {
          sentences = result;
          current_sentence = 0;
          stackframes = [];
          functions = Hashtbl.create 0;
          data = Hashtbl.create 0;
        }
    in
    let terminated = ref false in
    while not !terminated do
      let open Executor in
      let new_state, new_terminated = invoke_sentence !state in
      state := new_state;
      terminated := new_terminated
    done
  with Parsing.Parse_error ->
    print_endline @@ "Parse error: " ^ dump lexbuf.Lexing.lex_curr_p
