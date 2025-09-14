INCLUDE "defines.inc"

SECTION "GameinputOffset", ROM0

ReadInput::
    ldh a, [hPressedKeys]

CheckA::
	and PADF_A
    jp z, CheckB
SetA::
    ld a, 4
    ld [inputOffset], a
    ret

CheckB::
    ldh a, [hPressedKeys]
	and PADF_B
    jp z, CheckUp
SetB::
    ld a, 5
    ld [inputOffset], a
    ret

CheckUp::
    ldh a, [hPressedKeys]
    and PADF_UP 
    jp z, CheckDown
SetUp::
    ld a, 6
    ld [inputOffset], a
    ret

CheckDown::
    ldh a, [hPressedKeys]
    and PADF_DOWN
    jp z, CheckRight
SetDown::
    ld a, 7
    ld [inputOffset], a
    ret
    
CheckRight::
    ldh a, [hPressedKeys]
    and PADF_RIGHT 
    jp z, CheckLeft
SetRight::
    ld a, 8
    ld [inputOffset], a
    ret

CheckLeft::
    ldh a, [hPressedKeys]
    and PADF_LEFT 
    jp z, NoinputOffset
SetLeft::
    ld a, 9
    ld [inputOffset], a
    ret

NoinputOffset::
    xor a
    ld [inputOffset], a
    ret