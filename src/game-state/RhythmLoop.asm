
INCLUDE "defines.inc"

SECTION "RhythmVariables", WRAM0
def BEAT_TRIGGER equ 30
def FLASH_DURATION equ 5
def INPUT_WINDOW_FRAMES equ 5
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
    ; Increment loop counter
    ld a, [loopCounter]
    inc a
    ld [loopCounter], a

    ; 2 Beats per seconds (60hz) so every 30 frames we trigger the Beat
    cp BEAT_TRIGGER
    call nc, TriggerBeat

    ; Check Input command
    call CheckCommandOnBeat

    call SetBackgroundPalette
    
    ret

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

; Listen to input command
CheckCommandOnBeat::
    ; If after beat_trigger - 5
    ld a, [loopCounter]
    cp INPUT_WINDOW_FRAMES
    jp c, .acceptCommand
    ; If before beat_trigger + 5
    cp BEAT_TRIGGER - INPUT_WINDOW_FRAMES
    jp nc, .acceptCommand
    ret
.acceptCommand
    ld a, [hPressedKeys]
    cp 0
	call !z, ReadInput

    ; Display commands
	ld a, [inputOffset]
    cp 4
    call nc, DisplayInput
    ret

; Flash screen for FLASH_DURATION frames after the Beat
SetBackgroundPalette:::
    ld a, [loopCounter]
    cp FLASH_DURATION
    jp c, .setFlashPalette
.setBasePalette
    ld a, %11010100
	ld [rBGP], a
	ret
.setFlashPalette
	ld a, %11100100
	ld [rBGP], a
    ret
