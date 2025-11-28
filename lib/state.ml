type value = Int_value of int | String_value of string | Bool_value of bool

let value_ident = function
  | Int_value _ -> "i"
  | Bool_value _ -> "i" (* TODO *)
  | String_value _ -> "string"

type stackframe = { data : (string, value) Hashtbl.t; return_address : int }

type abap_state = {
  sentences : Ast.sentence list;
  current_sentence : int;
  stackframes : stackframe list;
  functions : (string, int) Hashtbl.t;
  data : (string, value) Hashtbl.t;
}

let advance_sentence state =
  { state with current_sentence = state.current_sentence + 1 }

let jump_to state index = { state with current_sentence = index }

let call_to state ?(data = Hashtbl.create 0) index =
  {
    state with
    stackframes =
      { data; return_address = state.current_sentence + 1 } :: state.stackframes;
    current_sentence = index;
  }

let pop_stackframe state =
  {
    state with
    stackframes = List.tl state.stackframes;
    current_sentence = (List.hd state.stackframes).return_address;
  }

let sentence_at state index = List.nth state.sentences index

let data_by_name state name =
  match state.stackframes with
  | hd_sf :: _ -> Hashtbl.find_opt hd_sf.data name
  | _ -> Hashtbl.find_opt state.data name

let add_data state name value =
  match state.stackframes with
  | hd_sf :: tl_sf ->
      let _ = Hashtbl.add hd_sf.data name value in
      { state with stackframes = hd_sf :: tl_sf }
  | _ ->
      {
        state with
        data =
          (let _ = Hashtbl.add state.data name value in
           state.data);
      }

let update_data state name value =
  match state.stackframes with
  | hd_sf :: tl_sf ->
      let _ = Hashtbl.replace hd_sf.data name value in
      { state with stackframes = hd_sf :: tl_sf }
  | _ ->
      {
        state with
        data =
          (let _ = Hashtbl.replace state.data name value in
           state.data);
      }
