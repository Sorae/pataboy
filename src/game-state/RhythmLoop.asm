
INCLUDE "defines.inc"

SECTION "RhythmVariables", WRAM0
DEF BEAT_TRIGGER EQU 30
DEF FLASH_DURATION EQU 5
DEF INPUT_WINDOW_FRAMES EQU 5
DEF MAX_BEAT EQU 4

loopCounter:: DS 1
beatCounter:: DS 1
isInBeatWindow:: DS 1
currentCommand:: DS 1 ; [0 (none), 1 (up), 2 (down), 3 (right), 4 (left)]

SECTION "RhythmLoop", ROMX

InitRhythmLoop::
    ; Initialize the rhythm loop variables
    xor a
    ld [loopCounter], a
    ld [beatCounter], a
    ld [isInBeatWindow], a
    ld [currentCommand], a    

    ret


UpdateRhythmLoop::
    ; Increment loop counter
    ld a, [loopCounter]
    inc a
    ld [loopCounter], a

    ; 2 Beats per seconds (60hz) so every 30 frames we trigger the Beat
    cp BEAT_TRIGGER
    call nc, TriggerBeat
    call DetectBeatWindow
    
    ; Check Input command
    call CheckCommandOnBeat
    call SetBackgroundPalette
    
    ret


TriggerBeat:
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


DetectBeatWindow:
    ; If after beat_trigger - 5
    ld a, [loopCounter]
    cp INPUT_WINDOW_FRAMES
    jp c, .inBeatWindow

    ; If before beat_trigger + 5
    cp BEAT_TRIGGER - INPUT_WINDOW_FRAMES
    jp nc, .inBeatWindow

.notInBeatWindow
    ;; return if already cleared
    ld a, [isInBeatWindow]
    cp 0

    ret z

    ; Clear beat
    xor a
    ld [isInBeatWindow], a

    ; if no current command, clear command pattern
    ld a, [currentCommand]
    cp 0
    call z, ClearPattern

    ret

.inBeatWindow
    ; return if already set
    ld a, [isInBeatWindow]
    cp 1

    ret z

    ; New beat
    ld a, 1
    ld [isInBeatWindow], a
    xor a
    ld [currentCommand], a

    ret 


; Listen to input command
CheckCommandOnBeat:
    ; Return if not in beat window
    ld a, [isInBeatWindow]
    cp 0

    ret z

    ; Return if no button pressed
    ld a, [hPressedKeys]
    cp 0

    ret z

	call ReadInput

    ; Set current command
	ld a, [inputOffset]
    ld [currentCommand], a

    ; Display commands
	ld a, [inputOffset]
    cp 4
    call nc, DisplayInput

    ret


; Flash screen for FLASH_DURATION frames after the Beat
SetBackgroundPalette:
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
