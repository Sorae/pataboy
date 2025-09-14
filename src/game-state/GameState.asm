INCLUDE "defines.inc"

SECTION "GameState", ROMX

InitGame::
    call InitBackground
    ; turn on display
    ld a, LCDCF_ON | LCDCF_BGON ;| LCDCF_OBJON
    ld [rLCDC], a
	; Init variables
	xor a
	ld [tileOffset], a
	ld [inputOffset], a
	call InitRhythmLoop

UpdateGame::
    call WaitVBlank
	; Update Ryhth Loop
	call UpdateRhythmLoop
    ; Listen to inputs
    ld a, [hPressedKeys]
    cp 0
	call !z, ReadInput

    ; Display commands
	ld a, [inputOffset]
    cp 4
    call nc, DisplayInput
    jp EndLoop

EndLoop::
    jp UpdateGame
