SECTION "Incompatible GB", ROMX
IncompatibleGBText:
    db "This game does not support\n"
    db "\t\tthe Original Game Boy.\\"

IncompatibleGBMap:
    db $01,$02,$03,$04,$05,$06,$07,$08,$09,$03,$0A,$0B,$0C,$0D,$0E,$0F
    db $10,$11,$00,$00,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D
    db $1E,$1F,$00,$00,$00,$00,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29
    db $2A,$2B,$2C,$2D,$2E,$00

IncompatibleGBTiles:
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $FE,$FE,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$00,$00
    db $82,$82,$80,$80,$82,$82,$F2,$F2,$8A,$8A,$8A,$8A,$8A,$8A,$00,$00
    db $00,$00,$00,$00,$78,$78,$80,$80,$70,$70,$08,$08,$F0,$F0,$00,$00
    db $00,$00,$00,$00,$38,$38,$44,$44,$45,$45,$45,$45,$3C,$3C,$04,$04
    db $00,$00,$E0,$E0,$15,$15,$F6,$F6,$14,$14,$14,$14,$F4,$F4,$00,$00
    db $00,$00,$00,$00,$63,$63,$94,$94,$97,$97,$94,$94,$93,$93,$00,$00
    db $00,$00,$00,$00,$80,$80,$41,$41,$C2,$C2,$02,$02,$C1,$C1,$00,$00
    db $20,$20,$20,$20,$27,$27,$E8,$E8,$28,$28,$28,$28,$E7,$E7,$00,$00
    db $00,$00,$00,$00,$1C,$1C,$A2,$A2,$BE,$BE,$A0,$A0,$1E,$1E,$00,$00
    db $00,$00,$00,$00,$58,$58,$65,$65,$45,$45,$45,$45,$44,$44,$00,$00
    db $01,$01,$01,$01,$E7,$E7,$11,$11,$11,$11,$11,$11,$E0,$E0,$00,$00
    db $00,$00,$00,$00,$C1,$C1,$02,$02,$01,$01,$00,$00,$C3,$C3,$00,$00
    db $00,$00,$00,$00,$E8,$E8,$08,$08,$C8,$C8,$28,$28,$C7,$C7,$00,$00
    db $00,$00,$00,$00,$BC,$BC,$A2,$A2,$A2,$A2,$A2,$A2,$3C,$3C,$20,$20
    db $00,$00,$00,$00,$F1,$F1,$8A,$8A,$8A,$8A,$8A,$8A,$F1,$F1,$80,$80
    db $00,$00,$00,$00,$CB,$CB,$2C,$2C,$28,$28,$28,$28,$C8,$C8,$00,$00
    db $08,$08,$08,$08,$BE,$BE,$08,$08,$08,$08,$08,$08,$06,$06,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$22,$22,$22,$22,$FA,$FA,$23,$23
    db $04,$04,$38,$38,$00,$00,$00,$00,$00,$00,$00,$00,$07,$07,$C8,$C8
    db $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02,$04,$04,$84,$84
    db $00,$00,$00,$00,$00,$00,$00,$00,$C0,$C0,$20,$20,$15,$15,$16,$16
    db $00,$00,$00,$00,$00,$00,$00,$00,$10,$10,$00,$00,$D3,$D3,$14,$14
    db $00,$00,$00,$00,$00,$00,$00,$00,$10,$10,$00,$00,$95,$95,$56,$56
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0E,$0E,$81,$81,$4F,$4F
    db $00,$00,$00,$00,$00,$00,$00,$00,$40,$40,$40,$40,$40,$40,$40,$40
    db $00,$00,$00,$00,$00,$00,$00,$00,$3C,$3C,$40,$40,$80,$80,$9C,$9C
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E0,$E0,$15,$15,$F6,$F6
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$63,$63,$94,$94
    db $00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$02,$02,$82,$82,$43,$43
    db $20,$20,$20,$20,$00,$00,$00,$00,$E0,$E0,$10,$10,$13,$13,$E4,$E4
    db $80,$80,$80,$80,$00,$00,$00,$00,$00,$00,$00,$00,$91,$91,$51,$51
    db $22,$22,$22,$22,$1A,$1A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $2F,$2F,$28,$28,$27,$27,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $84,$84,$02,$02,$81,$81,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $14,$14,$24,$24,$C4,$C4,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $14,$14,$14,$14,$13,$13,$00,$00,$00,$00,$03,$03,$00,$00,$00,$00
    db $54,$54,$54,$54,$D4,$D4,$40,$40,$40,$40,$80,$80,$00,$00,$00,$00
    db $51,$51,$51,$51,$4F,$4F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $40,$40,$40,$40,$30,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $85,$85,$45,$45,$3C,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $14,$14,$14,$14,$F4,$F4,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $97,$97,$94,$94,$93,$93,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $C2,$C2,$02,$02,$C3,$C3,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $14,$14,$14,$14,$E3,$E3,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $51,$51,$51,$51,$8F,$8F,$01,$01,$01,$01,$1E,$1E,$00,$00,$00,$00
    db $00,$00,$00,$00,$40,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

IncompatibleGB:
    ld a, %00000001
    ld [IE], a
    ei


; Play sound #1
    ld a, $0C ; envelope
    ld [NR12], a
    ld a, $7 | %10000000
    ld [NR14], a

; Slide out the Nintendo logo
    ld b, 3
.OuterLoop
    ld c, 4
.InnerLoop
    call WaitFrame
    ld a, [SCX]
    dec a
    ld [SCX], a
    dec c
    jr nz, .InnerLoop

    ld a, [BGP]
    sub %01000100
    ld [BGP], a
    dec b
    jr nz, .OuterLoop

; TODO: Place message in background tiles
;xor a
;ld [BGP], a

IncompatibleGBMapCopy
    call WaitFrame
    ld [LCDC], a

    ld a, 12 ; Get the scrolling ready in advance
    ld [SCX], a

    ld hl, $9901
    ld de, IncompatibleGBMap
    ld c, 3
.OuterLoop
    ld b, 18
.InnerLoop
    ld a, [de]
    inc de
    ld [hl+], a
    dec b
    jp nz, .InnerLoop

    ld a, c
    ld bc, 14
    add hl, bc
    ld c, a
    dec c
    jp nz, .OuterLoop

IncompatibleGBMapTilesCopy
    ld hl, $8000
    ld de, IncompatibleGBTiles
    ld bc, $02F0
.Loop
    ld a, [de]
    ld [hl+], a
    inc de
    dec c
    jr nz, .Loop

    ld a, b
    and a
    jr z, IncompatibleGBSlideIn
    dec b
    jr .Loop

IncompatibleGBSlideIn
; Play sound #2
    ld a, $72 ; envelope
    ld [NR12], a
    ld a, $2D
    ld [NR13], a
    ld a, $7 | %10000000
    ld [NR14], a

; Slide in the new message
    ld a, %10010001
    ld [LCDC], a

    ld b, 3
.OuterLoop
    ld c, 4
.InnerLoop
    call WaitFrame
    ld a, [SCX]
    dec a
    ld [SCX], a
    dec c
    jr nz, .InnerLoop

    ld a, [BGP]
    add %01000000
    ld [BGP], a
    dec b
    jr nz, .OuterLoop

    di

.HaltLoop
; Lock up the GB
    halt
    jr .HaltLoop
