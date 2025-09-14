INCLUDE "defines.inc"

SECTION "LevelVariables", WRAM0
tileOffset:: ds 1
inputOffset:: ds 1

SECTION "Level", romx
tileSetData: INCBIN "assets/tileset-drums.2bpp" ;"assets/tileset-arrows.2bpp"
tileSetEnd:

InitBackground::
	call WaitVBlank
    call ClearBackground
	; Copy the tile data
	ld de, tileSetData ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, tileSetEnd - tileSetData ; bc contains how many bytes we have to copy.
    call LCDMemcpy
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
	; add a, c
	; ld de, a
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


ClearBackground::
	; Turn the LCD off
	xor a
	ld [rLCDC], a

	ld bc, 1024
	ld hl, $9800

ClearBackgroundLoop:

	xor a
	ld [hli], a
	
	dec bc
	ld a, b
	or c

	jp nz, ClearBackgroundLoop

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

	ret