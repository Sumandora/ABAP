open State

let extern_var _state name =
  match name with
  | "WindowShouldClose" -> Bool_value (Raylib.window_should_close ())
  | _ -> failwith @@ "Unknown external variable: " ^ name
