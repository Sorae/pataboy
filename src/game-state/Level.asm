INCLUDE "defines.inc"

SECTION "LevelVariables", WRAM0
tileOffset:: ds 1
inputOffset:: ds 1

SECTION "Level", romx
tileSetData: INCBIN "assets/tileset-drums.2bpp" ;"assets/tileset-arrows.2bpp"
tileSetEnd:

InitBackground::
	call WaitVBlank
    ; Turn the LCD off
	xor a
	ld [rLCDC], a
    call ClearBackground
    call SetBackground
	; Copy the tile data
	ld de, tileSetData ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, tileSetEnd - tileSetData ; bc contains how many bytes we have to copy.
    call LCDMemcpy
    ; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON
	ld [rLCDC], a
    ret

DisplayInput::
	; Store inputOffset in b
	ld a, [inputOffset]
	ld b, a
	; Store tile position in de (index of first tile + tileOffset)
	ld a, [tileOffset]
	ld c, a
    ld de, $9908
	call OffsetDEByC
	; Get the command tile
    ld a, [hl]
    add a, b
	; Write the command on the given location
    ld [de], a
	; reset inputOffset
	xor a
	ld [inputOffset], a
	; increment tileoffset
	ld a, [tileOffset]
	inc a
	and 3 ; modulo 4
	ld [tileOffset],  a
    ret

; increment [c] times the value pointed by de
OffsetDEByC::
	ld a, c
    cp 0
	ret z
OffsetDEByC_Loop::
	inc de
	dec a
	ld c, a
	jp OffsetDEByC

; Set all screen to white background
ClearBackground::
	ld bc, 1024
	ld hl, $9800
    call ClearBackgroundLoop
    ret

ClearBackgroundLoop:
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jp nz, ClearBackgroundLoop

	ret

; Set Game Background which essentially is a border around the screen.
; This code checks HL for known VRAM addresses corresponding to border locations, but in an non optimized way.
SetBackground::
    ld bc, 1024
	ld hl, $9800
    call SetBackgroundLoop
    ret

SetBackgroundLoop:
    
SetTopLeftCorner:
    ; Check if HL points to $9800
    ld a, h
    cp $98
    jr nz, SetTopBorder
    ld a, l
    cp $00
    jr nz, SetTopBorder
    ld a, 10
    ld [hli], a
    jp EndBackgroundLoop
SetTopBorder:
    ld a, h
    cp $98
    jr nz, SetTopRightCorner
    ld a, l
    cp $00
    jr c, SetTopRightCorner
    cp $13
    jr nc, SetTopRightCorner
    ld a, 11
    ld [hli], a
    jp EndBackgroundLoop
SetTopRightCorner:
    ; Check if HL points to $9813
    ld a, h
    cp $98
    jr nz, SetLeftBorder
    ld a, l
    cp $13
    jr nz, SetLeftBorder
    ld a, 12
    ld [hli], a
    jp EndBackgroundLoop
SetLeftBorder:
    ; Check all possible VRAM locations for the left border
    ld a, h
    cp $98
    jr nz, .checkLeft99s
    ; check h $98 values
    ld a, l
    cp $20
    jr z, .setLeftBorderTile
    cp $40
    jr z, .setLeftBorderTile
    cp $60
    jr z, .setLeftBorderTile
    cp $80
    jr z, .setLeftBorderTile
    cp $A0
    jr z, .setLeftBorderTile
    cp $C0
    jr z, .setLeftBorderTile
    cp $E0
    jr z, .setLeftBorderTile
    jr nz, SetRightBorder
.checkLeft99s
    ld a, h
    cp $99
    jr nz, .checkLeft9As
    ld a, l
    cp $00
    jr z, .setLeftBorderTile
    cp $20
    jr z, .setLeftBorderTile
    cp $40
    jr z, .setLeftBorderTile
    cp $60
    jr z, .setLeftBorderTile
    cp $80
    jr z, .setLeftBorderTile
    cp $A0
    jr z, .setLeftBorderTile
    cp $C0
    jr z, .setLeftBorderTile
    cp $E0
    jr z, .setLeftBorderTile
    jr nz, SetRightBorder
    ; check h $9A values
.checkLeft9As
    ld a, h
    cp $9A
    jr nz, SetRightBorder
    ld a, l
    cp $00
    jr nz, SetRightBorder
.setLeftBorderTile
    ld a, 13
    ld [hli], a
    jp EndBackgroundLoop
SetRightBorder:
    ; Check all possible VRAM locations for the right border
    ld a, h
    cp $98
    ; check h $98 values
    jr nz, .checkRight99s
    ld a, l
    cp $33
    jr z, .setRightBorderTile
    cp $53
    jr z, .setRightBorderTile
    cp $73
    jr z, .setRightBorderTile
    cp $93
    jr z, .setRightBorderTile
    cp $B3
    jr z, .setRightBorderTile
    cp $D3
    jr z, .setRightBorderTile
    cp $F3
    jr z, .setRightBorderTile
    jr nz, SetBottomLeftCorner
.checkRight99s
    ld a, h
    cp $99
    jr nz, .checkRight9As
    ld a, l
    cp $13
    jr z, .setRightBorderTile
    cp $33
    jr z, .setRightBorderTile
    cp $53
    jr z, .setRightBorderTile
    cp $73
    jr z, .setRightBorderTile
    cp $93
    jr z, .setRightBorderTile
    cp $B3
    jr z, .setRightBorderTile
    cp $D3
    jr z, .setRightBorderTile
    cp $F3
    jr z, .setRightBorderTile
    jr nz, SetBottomLeftCorner
    ; check h $9A values
.checkRight9As
    ld a, h
    cp $9A
    jr nz, SetBottomLeftCorner
    ld a, l
    cp $13
    jr z, .setRightBorderTile
    jr nz, SetBottomLeftCorner 
.setRightBorderTile
    ld a, 14
    ld [hli], a
    jp EndBackgroundLoop
SetBottomLeftCorner:
    ; Check if HL points to $9A20
    ld a, h
    cp $9A
    jr nz, SetBottomBorder
    ld a, l
    cp $20
    jr nz, SetBottomBorder
    ld a, 16
    ld [hli], a
    jp EndBackgroundLoop
SetBottomBorder:
    ld a, h
    cp $9A
    jr nz, SetBottomRightCorner
    ld a, l
    cp $20
    jr c, SetBottomRightCorner
    cp $33
    jr nc, SetBottomRightCorner
    ld a, 17
    ld [hli], a
    jp EndBackgroundLoop
SetBottomRightCorner:
    ; Check if HL points to $9A33
    ld a, h
    cp $9A
    jr nz, SetCenterTile
    ld a, l
    cp $33
    jr nz, SetCenterTile
    ld a, 18
    ld [hli], a
    jp EndBackgroundLoop
    ; decrease counter and loop
SetCenterTile:
    xor a
    ld [hli], a
EndBackgroundLoop:
	dec bc
	ld a, b
	or c
	jp nz, SetBackgroundLoop
	ret

    
