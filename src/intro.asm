INCLUDE "defines.inc"

SECTION "Intro", ROMX

Intro::
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a
	
	call GameState