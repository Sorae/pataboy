INCLUDE "defines.inc"

SECTION "GameState", ROMX

GameState::
.init
    call InitBackground

    ; turn on display
    ld a, LCDCF_ON | LCDCF_BGON ;| LCDCF_OBJON
    ld [rLCDC], a

	; Init variables
	xor a
	ld [tileOffset], a
	ld [inputOffset], a
	call InitRhythmLoop

.loop
    call WaitVBlank
	; Update Ryhth Loop
	call UpdateRhythmLoop

.end
    jp GameState.loop
