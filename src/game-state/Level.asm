INCLUDE "defines.inc"

SECTION "LevelVariables", WRAM0
tileOffset:: DS 1
inputOffset:: DS 1

SECTION "Level", ROMX
TileSetData: 
    INCBIN "assets/tileset-drums.2bpp" ;"assets/tileset-arrows.2bpp"
.end

InitBackground::
	call WaitVBlank

    ; Turn the LCD off
	xor a
	ld [rLCDC], a
    call ClearBackground
    call SetBackground

	; Copy the tile data
	ld de, TileSetData ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, TileSetData.end - TileSetData ; bc contains how many bytes we have to copy.
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

ClearPattern::
    ; Clear the input pattern on screen
    ld hl, $9908
    ld a, 4
    ld b, a

.loop
    xor a
    ld [hli], a
    dec b
    ld a, b
    cp 0
    jp nz, ClearPattern.loop
    xor a
    ld [tileOffset], a

    ret

; increment [c] times the value pointed by de
OffsetDEByC:
	ld a, c
    cp 0

	ret z

OffsetDEByC_Loop:
	inc de
	dec a
	ld c, a
	jp OffsetDEByC

; Set all screen to white background
ClearBackground:
	ld bc, 1024
	ld hl, $9800
    call ClearBackground.loop

    ret

.loop
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jp nz, ClearBackground.loop

	ret

; Set Game Background which essentially is a border around the screen.
; This code checks HL for known VRAM addresses corresponding to border locations, in an non-optimized way.
SetBackground:
    ld bc, 1024
	ld hl, $9800
    call .loop

    ret

.loop
.setTopLeftCorner
    ; Check if HL points to $9800
    ld a, h
    cp $98
    jr nz, .setTopBorder
    ld a, l
    cp $00
    jr nz, .setTopBorder
    ld a, 10
    ld [hli], a
    jp .loop

.setTopBorder:
    ; Check if HL points to $9813
    ld a, h
    cp $98
    jr nz, .setTopRightCorner
    ld a, l
    cp $00
    jr c, .setTopRightCorner
    cp $13
    jr nc, .setTopRightCorner
    ld a, 11
    ld [hli], a
    jp .loop

.setTopRightCorner:
    ; Check if HL points to $9813
    ld a, h
    cp $98
    jr nz, .setLeftBorder
    ld a, l
    cp $13
    jr nz, .setLeftBorder
    ld a, 12
    ld [hli], a
    jp .loop

.setLeftBorder:
    ; Check all possible VRAM locations for the left border
    ld a, h
    cp $98
    jr nz, .checkLeft99s

.checkLeft98s
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
    jr nz, .setRightBorder

.checkLeft99s
    ; check h $99 values
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
    jr nz, .setRightBorder

.checkLeft9As
    ; check h $9A values
    ld a, h
    cp $9A
    jr nz, .setRightBorder
    ld a, l
    cp $00
    jr nz, .setRightBorder

.setLeftBorderTile
    ld a, 13
    ld [hli], a
    jp .loop

; Check all possible VRAM locations for the right border
.setRightBorder:
    ld a, h
    cp $98
    jr nz, .checkRight99s

.checkRight98s
    ; check h $98 values
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
    jr nz, .setBottomLeftCorner

.checkRight99s
    ; check h $99 values
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
    jr nz, .setBottomLeftCorner

; check h $9A values
.checkRight9As
    ld a, h
    cp $9A
    jr nz, .setBottomLeftCorner
    ld a, l
    cp $13
    jr z, .setRightBorderTile
    jr nz, .setBottomLeftCorner

.setRightBorderTile
    ld a, 14
    ld [hli], a
    jp .loop
    
.setBottomLeftCorner:
    ; Check if HL points to $9A20
    ld a, h
    cp $9A
    jr nz, .setBottomBorder
    ld a, l
    cp $20
    jr nz, .setBottomBorder
    ld a, 16
    ld [hli], a
    jp .loop

.setBottomBorder:
    ld a, h
    cp $9A
    jr nz, .setBottomRightCorner
    ld a, l
    cp $20
    jr c, .setBottomRightCorner
    cp $33
    jr nc, .setBottomRightCorner
    ld a, 17
    ld [hli], a
    jp .loop

.setBottomRightCorner:
    ; Check if HL points to $9A33
    ld a, h
    cp $9A
    jr nz, .setCenterTile
    ld a, l
    cp $33
    jr nz, .setCenterTile
    ld a, 18
    ld [hli], a
    jp .loop
    ; decrease counter and loop

.setCenterTile:
    xor a
    ld [hli], a

.end:
	dec bc
	ld a, b
	or c
	jp nz, .loop

	ret
