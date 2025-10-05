INCLUDE "defines.inc"

SECTION "GameinputOffset", ROM0

; Read the current input and store it in inputOffset
ReadInput::
    ldh a, [hPressedKeys]

; Check if A is pressed
.checkA
    and PADF_A
    jp z, .checkB
.setA
    ld a, 4
    ld [inputOffset], a

    ret

; Check if B is pressed
.checkB
    ldh a, [hPressedKeys]
    and PADF_B
    jp z, .checkUp
.setB
    ld a, 5
    ld [inputOffset], a

    ret

; Check if the UP D-pad is pressed
.checkUp
    ldh a, [hPressedKeys]
    and PADF_UP 
    jp z, .checkDown
.setUp
    ld a, 6
    ld [inputOffset], a

    ret

; Check if the DOWN D-pad is pressed
.checkDown
    ldh a, [hPressedKeys]
    and PADF_DOWN
    jp z, .checkRight
.setDown
    ld a, 7
    ld [inputOffset], a

    ret

; Check if the RIGHT D-pad is pressed
.checkRight
    ldh a, [hPressedKeys]
    and PADF_RIGHT 
    jp z, .checkLeft
.setRight
    ld a, 8
    ld [inputOffset], a

    ret

; Check if the LEFT D-pad is pressed    
.checkLeft
    ldh a, [hPressedKeys]
    and PADF_LEFT 
    jp z, .noInputOffset
.setLeft
    ld a, 9
    ld [inputOffset], a

    ret

; No input detected, set inputOffset to 0
.noInputOffset
    xor a
    ld [inputOffset], a

    ret
