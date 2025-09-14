
INCLUDE "defines.inc"

SECTION "RhythmVariables", WRAM0
def BEAT_TRIGGER equ 30
def FLASH_DURATION equ 5
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
    ; 2 Beats per seconds (60hz) so every 30 frames we trigger the Beat
    cp BEAT_TRIGGER
    call nc, TriggerBeat
    ; Flash screen for FLASH_DURATION frames after the Beat
    ld [loopCounter], a
    cp FLASH_DURATION
    jp c, FlashScreen
    jp SetBasePalet

TriggerBeat::
    ; Reset counter
    xor a
    ld [loopCounter], a
    ; Increment beat
    ld a, 1
    ld [beatCounter], a
    ; Modulo 4 (Max beat)
    ld a, [beatCounter]
    and MAX_BEAT - 1
    ld [beatCounter], a
    ret

FlashScreen::
	ld a, %11100100
	ld [rBGP], a

    jp EndRhythmLoop
    
SetBasePalet::
    ld a, %11010100
	ld [rBGP], a
	jp EndRhythmLoop

EndRhythmLoop::
    ret