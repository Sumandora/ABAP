(* hacky *)
let img_map = ref []
let tex_map = ref []

let extern_call state f (args : Ast.expr list) =
  match (f, args) with
  | "InitWindow", [ w; h; name ] ->
      Raylib.init_window (Expr.to_int state w) (Expr.to_int state h)
        (Expr.to_string state name);
      state
  | "SetTargetFPS", [ fps ] ->
      Raylib.set_target_fps (Expr.to_int state fps);
      state
  | "CloseWindow", [] ->
      Raylib.close_window ();
      state
  | "BeginDrawing", [] ->
      Raylib.begin_drawing ();
      state
  | "EndDrawing", [] ->
      Raylib.end_drawing ();
      state
  | "ClearBackground", [ r; g; b; a ] ->
      Raylib.clear_background
      @@ Raylib.Color.create (Expr.to_int state r) (Expr.to_int state g)
           (Expr.to_int state b) (Expr.to_int state a);
      state
  (* Deallocation is for pussies *)
  | "LoadImage", [ path; Word "INTO"; Word variable ] ->
      let img = Raylib.load_image (Expr.to_string state path) in
      let img_id = List.length !img_map in
      img_map := !img_map @ [ img ];
      State.add_data state variable (Int_value img_id)
  | "LoadTextureFromImage", [ img_id; Word "INTO"; Word variable ] ->
      let img_id = Expr.to_int state img_id in
      let img = List.nth !img_map img_id in

      let texture = Raylib.load_texture_from_image img in

      let tex_id = List.length !tex_map in
      tex_map := !tex_map @ [ texture ];

      State.add_data state variable (Int_value tex_id)
  | "DrawTexture", [ tex_id; x; y ] ->
      let texture = List.nth !tex_map (Expr.to_int state tex_id) in
      (* Since I don't think I'll ever need tint, I won't implement it *)
      Raylib.draw_texture texture (Expr.to_int state x) (Expr.to_int state y)
        Raylib.Color.white;
      state
  (* hacky *)
  | "DrawTextureScaled", [ tex_id; x; y; scale ] ->
      let texture = List.nth !tex_map (Expr.to_int state tex_id) in
      Raylib.draw_texture_ex texture
        (Raylib.Vector2.create
           (Float.of_int @@ Expr.to_int state x)
           (Float.of_int @@ Expr.to_int state y))
        0.0
        ((Float.of_int @@ Expr.to_int state scale) /. 100.0)
        Raylib.Color.white;
      state
  | "SetRandomSeed", [ seed ] ->
      Raylib.set_random_seed @@ Unsigned.UInt.of_int (Expr.to_int state seed);
      state
  | "GetRandomValue", [ min; max; Word "INTO"; Word variable ] ->
      let rng_num =
        Raylib.get_random_value (Expr.to_int state min) (Expr.to_int state max)
      in
      if Option.is_some @@ State.data_by_name state variable then
        State.update_data state variable (Int_value rng_num)
      else State.add_data state variable (Int_value rng_num)
  | "IsKeyPressed", [ key; Word "INTO"; Word variable ] ->
      let pressed =
        Raylib.is_key_pressed @@ Raylib.Key.of_int (Expr.to_int state key)
      in
      if Option.is_some @@ State.data_by_name state variable then
        State.update_data state variable (Bool_value pressed)
      else State.add_data state variable (Bool_value pressed)
  | _ ->
      failwith @@ "Unknown extern call: " ^ f ^ " "
      ^ List.fold_left (fun acc e -> acc ^ " " ^ Expr.printable e) "" args
