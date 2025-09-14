
INCLUDE "defines.inc"

SECTION "RhythmVariables", WRAM0
def BEAT_TRIGGER equ 30
def MAX_BEAT equ 4

loopCounter:: ds 1
beatCounter:: ds 1

SECTION "RhythmLoop", romx

InitRhythmLoop::
    ; Initialize the rhythm loop variables
    xor a
    ld [loopCounter], a
    ld [beatCounter], a
    ret

UpdateRhythmLoop::
    ld a, [loopCounter]
    inc a
    ld [loopCounter], a
    ; 2 Beat per seconds (60hz) so every 30 frames we tigger the Beat
    cp BEAT_TRIGGER
    jp nc, TriggerBeat
    jp SetBasePalet

TriggerBeat::
    ; Reset counter
    xor a
    ld [loopCounter], a
    call FlashScreen
    jp EndRhythmLoop

FlashScreen::
	ld a, $FF
	ld [rBGP], a
	ret

SetBasePalet::
	ld a, %11100100
	ld [rBGP], a
	jp EndRhythmLoop

EndRhythmLoop::
    ret