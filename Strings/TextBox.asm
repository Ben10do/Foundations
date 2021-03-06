INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/StringMacros.inc"
INCLUDE "lib/Shift.inc"

IMPORT TextTilesPointer, CopyChar

; SECTION "Text Box Map",

SECTION "Text Boxes", ROM0

ShowTextBox::
    SwitchWRAMBank BANK(TextTilesPointer)
    xor a
    ld [PrintSettings], a

.SetUpWindow
    ld hl, LCDC
    ld a, %01100000 ; Set the map for the window, and enable the window.
    or a, [hl]
    ld [hl], a

.SetInitialWindowPosition
    ld a, 144
    ld [WY], a
    ld a, 7
    ld [WX], a

.SetPalettes
    call SetDefaultTextColours
    call EnsureVRAMAccess

.SetMapAttributes
    ; TODO: Use DMA
    ld a, 1
    ld [VBK], a
    ei

    ld hl, $9C00
    ld de, 12
    ld b, 6
    ld c, 20
.MapAttributesLoop
    call EnsureVRAMAccess
    ld a, (7 | %1000) ; TODO: Write a description
    ld [hl+], a
    ei
    dec c
    jr nz, .MapAttributesLoop

    add hl, de
    ld c, 20
    dec b
    jr nz, .MapAttributesLoop
    jr .SetTiles

.SetMapLayout
    ; TODO: Use DMA?
    xor a
    ld [VBK], a ; Use VRAM Bank 0

    ld hl, $9C00 + $21
    ld a, TileID + 1
    ld b, 5
    ld c, 18
    ld d, a
.MapLayoutLoop
    call EnsureVRAMAccess
    ld a, d
    ld [hl+], a
    ei
    inc a
    ld d, a
    dec c
    jr nz, .MapLayoutLoop

    ld de, 14
    add hl, de
    ld d, a
    ld c, 18
    dec b
    jr nz, .MapLayoutLoop
    ld de, OpeningSound
    ld hl, WY
    jr .AnimationLoop

.AnimationSoundFX
; TODO: Eliminate this in favour of a much better sound engine
    ld a, $81
    ld [NR12], a
    ld a, [de]
    ld [NR13], a
    inc de
    ld a, [de]
    ld [NR14], a
    inc de
    jr .AnimationLoop

.SetTiles
    call ClearTextBox
    ld hl, WY

.AnimationLoop
; Move the window up by 4px every frame, until it's 48px tall.
; TODO: Need to ensure that sprites are hidden behind the window!
    call WaitFrame
    ld a, ($100 - 4)
    add a, [hl]
    ld [hl], a
    
    cp (144 - 4)
    jr z, .SetMapLayout

    cp (144 - 24)
    jr nc, .AnimationSoundFX

    cp (144 - 48)
    jr nz, .AnimationLoop

    jp WaitFrame

OpeningSound
    db %00010001, %10000101
    db %10110100, %10000101
    db %01000100, %10000111
    db %01110011, %00000111
    db %01000100, %10000111

CloseTextBox::
    ld de, ClosingSound
    ld hl, WY

.AnimationLoop
; Move the window down by 4px every frame, until it's off-screen.
    call WaitFrame
    ld a, 4
    add a, [hl]
    ld [WY], a
    cp (144 - 24)
    jr c, .AnimationSoundFX
    cp 144
    jr nz, .AnimationLoop

    ret

.AnimationSoundFX
; Replace with call to sound engine!
    ld a, $81
    ld [NR12], a
    ld a, [de]
    ld [NR13], a
    inc de
    ld a, [de]
    ld [NR14], a
    inc de
    jr .AnimationLoop

ClosingSound:
    db %01000100, %10000111
    db %00000101, %10000111
    db %01110010, %10000110
    db %00010101, %00000100
    db %00010001, %10000101

PlayTextBeep::
    ld a, %10000000 | $3B
    ld [NR11], a

    ld a, $31
    ld [NR12], a

    ld a, %11010110
    ld [NR13], a

    ld a, %11000110
    ld [NR14], a

    ret


ReplaceLastTile::
; assume that *b* has the desired tile no., e.g. the next arrow
    ld a, $84
    ld a, $80
    ld a, b
    call CopyChar

; Source in bc
; Destination in hl
; Current tile in a
; Counter in d
; e has the colouration
    ld a, 1
    ld [VBK], a
    ld bc, TextTilesWorkSpace
    ld hl, TilesPosition + (4 * TilesPerLine) ; $8480
    ld e, 1
    push de
    ld e, 3
    ld d, 8

.TileCopyLoop
    ld a, [bc]
    push bc
    call Convert1BitTileLine
    call EnsureVRAMAccess
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl+], a
    ei
    pop bc
    inc bc
    dec d
    jr nz, .TileCopyLoop

    pop de
    dec e
    ret z
    push de
    ld e, 3
    jr .TileCopyLoop


FastFadeText::
; A more specialised version of the function that was once above it
; Fades out the text and the prompt cursor
    call WaitFrame
    ld d, 3 ; Outer counter
.OuterLoop
    ld b, 4 ; Number of colours to modify
    ld c, 56 ; Address
.BGPaletteLoop
; Load the palette into hl
    inc c
    ld a, c
    ld [BGPI], a

    call EnsureVRAMAccess
    ld a, [BGPD]
    ei
    ld h, a

    dec c
    ld a, c
    inc c
    inc c

    set 7, a ; Increment after writing
    ld [BGPI], a
    call EnsureVRAMAccess
    ld a, [BGPD]
    ei
    ld l, a

; Manipulate the palette data
    srl16 hl, 1
    call EnsureVRAMAccess
    ld a, l
    and %11100111
    ld [BGPD], a

    ld a, h
    and %00011100
    ld [BGPD], a
    ei

    dec b
    jr nz, .BGPaletteLoop

; Fade out the prompt cursor
.SpritePalette
    ld b, 63 | (1 << 7) ; Address (+ increment on write)
    ld a, b
    ld [OBPI], a
    call EnsureVRAMAccess
    ld a, [OBPD]
    ei
    ld h, a

    dec b
    ld a, b
    ld [OBPI], a
    call EnsureVRAMAccess
    ld a, [OBPD]
    ei
    ld l, a

; Manipulate the palette data
    srl16 hl, 1
    call EnsureVRAMAccess
    ld a, l
    and %11100111
    ld [OBPD], a

    ld a, h
    and %00011100
    ld [OBPD], a
    ei

    call WaitFrame
    call WaitFrame
    dec d
    jr nz, .OuterLoop
    ret
