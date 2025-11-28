#!/usr/bin/env -S dune exec abap
REPORT casino.

CALL EXTERN InitWindow 1280 960 'Hello from ABAP!'.

CALL EXTERN SetTargetFPS 60.

CALL EXTERN LoadImage './book_of_sap.png' INTO book_of_sap_img.
CALL EXTERN LoadTextureFromImage book_of_sap_img INTO book_of_sap_tex.

CALL EXTERN LoadImage './j.png' INTO j_img.
CALL EXTERN LoadTextureFromImage j_img INTO j_tex.

CALL EXTERN LoadImage './10.png' INTO 10_img.
CALL EXTERN LoadTextureFromImage 10_img INTO 10_tex.

CALL EXTERN LoadImage './k.png' INTO k_img.
CALL EXTERN LoadTextureFromImage k_img INTO k_tex.

CALL EXTERN LoadImage './bird.png' INTO bird_img.
CALL EXTERN LoadTextureFromImage bird_img INTO bird_tex.

CALL EXTERN LoadImage './pharaoh.png' INTO pharaoh_img.
CALL EXTERN LoadTextureFromImage pharaoh_img INTO pharaoh_tex.

CALL EXTERN LoadImage './a.png' INTO a_img.
CALL EXTERN LoadTextureFromImage a_img INTO a_tex.

CALL EXTERN LoadImage './bug.png' INTO bug_img.
CALL EXTERN LoadTextureFromImage bug_img INTO bug_tex.

CALL EXTERN LoadImage './q.png' INTO q_img.
CALL EXTERN LoadTextureFromImage q_img INTO q_tex.

" the legend
CALL EXTERN LoadImage './lars.png' INTO lars_img.
CALL EXTERN LoadTextureFromImage lars_img INTO lars_tex.

CALL EXTERN GetRandomValue 0 696969 INTO initial_seed.
DATA seed TYPE i VALUE initial_seed.

WHILE !EXT_WindowShouldClose.
	CALL EXTERN BeginDrawing.

	CALL EXTERN ClearBackground 0 0 0 255.

	CALL EXTERN DrawTexture book_of_sap_tex 0 0.

	CALL EXTERN SetRandomSeed seed.

	DATA x TYPE i VALUE 0.
	WHILE x < 5.

		DATA y TYPE i VALUE 0.
		WHILE y < 4.

			DATA img TYPE i VALUE 0.
			CALL EXTERN GetRandomValue 0 7 INTO rng_num.
			IF rng_num == 0.
				img = j_tex.
			ENDIF.
			IF rng_num == 1.
				img = 10_tex.
			ENDIF.
			IF rng_num == 2.
				img = k_tex.
			ENDIF.
			IF rng_num == 3.
				img = bird_tex.
			ENDIF.
			IF rng_num == 4.
				img = pharaoh_tex.
			ENDIF.
			IF rng_num == 5.
				img = a_tex.
			ENDIF.
			IF rng_num == 6.
				img = bug_tex.
			ENDIF.
			IF rng_num == 7.
				img = q_tex.
			ENDIF.

			CALL EXTERN DrawTexture img (x * 256) (215 + y * 256).

			y = y + 1.

		ENDWHILE.

		x = x + 1.

	ENDWHILE.

	CALL EXTERN DrawTextureScaled lars_tex 0 (960 - 600 / 2) 50.

	CALL EXTERN IsKeyPressed 32 INTO space_pressed.
	IF space_pressed.
		CALL EXTERN GetRandomValue 0 69696969 INTO new_seed.
		seed = new_seed.
		WRITE 'reroll'.
	ENDIF.

	CALL EXTERN EndDrawing.
ENDWHILE.

CALL EXTERN CloseWindow.
