; function that displays the start menu
DrawStartMenu::
	CheckEvent EVENT_GOT_POKEDEX
; menu with pokedex
	hlcoord 10, 0
	ld b, $0e
	ld c, $08
	jr nz, .drawTextBoxBorder
; shorter menu if the player doesn't have the pokedex
	hlcoord 10, 0
	ld b, $0c
	ld c, $08
.drawTextBoxBorder
	call TextBoxBorder
	ld a, D_DOWN | D_UP | START | B_BUTTON | A_BUTTON
	ld [wMenuWatchedKeys], a
	ld a, $02
	ld [wTopMenuItemY], a ; Y position of first menu choice
	ld a, $0b
	ld [wTopMenuItemX], a ; X position of first menu choice
	ld a, [wBattleAndStartSavedMenuItem] ; remembered menu selection from last time
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	xor a
	ld [wMenuWatchMovingOutOfBounds], a
	ld hl, wStatusFlags5
	set BIT_NO_TEXT_DELAY, [hl]
	hlcoord 12, 2
	CheckEvent EVENT_GOT_POKEDEX
; case for not having pokedex
	ld a, $06
	jr z, .storeMenuItemCount
; case for having pokedex
	ld de, StartMenuPokedexText
	call PrintStartMenuItem
	ld a, $07
.storeMenuItemCount
	ld [wMaxMenuItem], a ; number of menu items
	ld de, StartMenuPokemonText
	call PrintStartMenuItem
	ld de, StartMenuItemText
	call PrintStartMenuItem
	ld de, wPlayerName ; player's name
	call PrintStartMenuItem
	ld a, [wStatusFlags4]
	bit BIT_LINK_CONNECTED, a
; case for not using link feature
	ld de, StartMenuSaveText
	jr z, .printSaveOrResetText
; case for using link feature
	ld de, StartMenuResetText
.printSaveOrResetText
	call PrintStartMenuItem
	ld de, StartMenuOptionText
	call PrintStartMenuItem
	ld de, StartMenuExitText
	call PlaceString
	ld hl, wStatusFlags5
	res BIT_NO_TEXT_DELAY, [hl]
	ret

StartMenuPokedexText:
	db "POKéDEX@"

StartMenuPokemonText:
	db "POKéMON@"

StartMenuItemText:
	db "ITEM@"

StartMenuSaveText:
	db "SAVE@"

StartMenuResetText:
	db "RESET@"

StartMenuExitText:
	db "EXIT@"

StartMenuOptionText:
	db "OPTION@"

PrintStartMenuItem:
	push hl
	call PlaceString
	pop hl
	ld de, SCREEN_WIDTH * 2
	add hl, de
	ret

DrawMenuAccount::
; prints a short blurb about the
; current selection, just like in GSC
	hlcoord 0, 13
	lb bc, 5, 10
	call ClearScreenArea
	ld a, [wStatusFlags4]
	bit BIT_LINK_CONNECTED, a
	ld de, .EntriesLink
	jr nz, .check_pokedex
	ld de, .Entries
.check_pokedex
	CheckEvent EVENT_GOT_POKEDEX
	ld a, [wCurrentMenuItem]
	jr nz, .got_table
	inc a
.got_table
	add a
	ld l, a
	ld h, 0
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	hlcoord 0, 14
	jp PlaceString

.Entries
	dw .Pokedex
	dw .Pokemon
	dw .Item
	dw .Player
	dw .Save
	dw .Option
	dw .Exit

.EntriesLink
	dw .Pokedex
	dw .Pokemon
	dw .Item
	dw .Player
	dw .Reset
	dw .Option
	dw .Exit

.Pokedex
	db "#MON"
	next "database@"

.Pokemon
	db "Party <PKMN>"
	next "status@"

.Item
	db "Contains"
	next "items@"

.Player
	db "Your own"
	next "status@"

.Save
	db "Save your"
	next "progress@"

.Reset
	db "Soft-reset"
	next "the game@"

.Option
	db "Change"
	next "settings@"

.Exit
	db "Close this"
	next "menu@"
