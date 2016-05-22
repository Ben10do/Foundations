SECTION "BankSwitchData", HRAM
CurrentROMBank:  db

SECTION "BankSwitch", ROM0
SRAMEnableLocation EQU $0000
ROMBankSwitchLocation EQU $2000
SRAMBankSwitchLocation EQU $4000
WRAMBankSwitchLocation EQU $FF70

CallToOtherBankFunction:
; assumes *c* is the requested bank - different to other functions!
; assumes hl is the address required within said bank
; use b and de to pass data there, and bc, de, and hl to pass data back
; requires 6 bytes of stack space for each inter-bank call.
    ldh a, [CurrentROMBank]
    push af
    ld a, c

    ldh [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a

; Simulate a call
    ld a, b
    ld bc, .Return
    push bc
    ld b, a
    jp hl
.Return
    pop af
    ldh [CurrentROMBank], a

    ld [ROMBankSwitchLocation], a
    ret


CallToOtherBank: MACRO
    ld c, BANK(\1)
    ld hl, \1
    call CallToOtherBankFunction
    ENDM


JumpToOtherBankFunction:
; assumes *a* is the requested bank
; assumes hl is the address required within said bank
; use bc and de to pass data there
    ldh [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a
    jp hl


JumpToOtherBank: MACRO
    ld a, BANK(\1)
    ld hl, \1
    jp JumpToOtherBankFunction
    ENDM


SwitchROMBank: MACRO
    ld a, \1
    SwitchROMBankFromRegister
    ENDM


SwitchROMBankFromRegister: MACRO
; assumes *a* is the requested bank
    ldh [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a
    ENDM


PushROMBank: MACRO
    ldh a, [CurrentROMBank]
    push af
    ENDM


PopROMBank: MACRO
    pop af
    SwitchROMBankFromRegister
    ENDM


EnableSRAM: MACRO
    ld a, $0A
    ld [ResetDisallowed], a
    ld [SRAMEnableLocation], a
    ENDM


DisableSRAM: MACRO
    xor a
    ld [SRAMEnableLocation], a
    ld [ResetDisallowed], a
    ENDM


SwitchSRAMBank: MACRO
    ld a, \1
    ld [SRAMBankSwitchLocation], a
    ENDM


SwitchWRAMBank: MACRO
    ld a, \1
    ld [WRAMBankSwitchLocation], a
    ENDM


PushWRAMBank: MACRO
    ld a, [WRAMBankSwitchLocation]
    push af
    ENDM


PopWRAMBank: MACRO
    pop af
    ld [WRAMBankSwitchLocation], a
    ENDM


SECTION "GBC Subroutines", ROM0

KEY1 EQU $FF4D

SwitchSpeed: MACRO
    ld a, 1
    ld [KEY1], a
    stop
    ENDM

EnableDoubleSpeed: MACRO
; Switches to double speed if we're not already in double speed mode.
    ld a, [KEY1]
    bit 7, a
    jr nz, .Done\@
.Switch\@
    SwitchSpeed
.Done\@
    ENDM

DisableDoubleSpeed: MACRO
; Switches to regular speed if we're currently in double speed mode.
    ld a, [KEY1]
    bit 7, a
    jr z, .Done\@
.Switch\@
    SwitchSpeed
.Done\@
    ENDM


StartVRAMDMA: MACRO
; Assuming the DMA Wait Routine is in HRAM already
; \1: Source, \2: Destination, \3: Length, \4: 0 = General, 1 = H-Blank
    ;IF \1 & $F != 0
    ;WARN "DMA Souce address's lower four bits must be 0."
    ;ENDC

    ;IF \2 & $F != 0
    ;WARN "DMA Destination address's lower four bits must be 0."
    ;ENDC

    ld a, (\1 >> 8)
    ld [HDMA1], a
    ld a, (\1 & $FF)
    ld [HDMA2], a

    ld a, (\2 >> 8)
    ld [HDMA3], a
    ld a, (\2 & $FF)
    ld [HDMA4], a

    ld a, (((\3 / $10) - 1) & $7F) | ((\4 & 1) << 7)
    ld [HDMA5], a
    ENDM


WaitForVRAMDMAToFinish: MACRO
.Loop\@
    ld a, [HDMA5]
    cp $FF
    jr nz, .Loop\@
    ENDM


StartOAMDMA: MACRO
    di
    ld a, \1 >> 8
    call OAMDMAWait
    ei
    ENDM


SECTION "DMA Wait Location", HRAM
OAMDMAWait:: ds 8


SECTION "DMA Wait Subroutine", ROM0
DMAWaitInROM::
    ld [ODMA], a
    ld a, $28
.Wait
    dec a
    jr nz, .Wait
    ret



SECTION "Graphics Subroutines", ROM0
WaitFrame:
; Returns after the next V-Blank begins, and the interrupt is finished.
    ld a, 1
    ldh [VBlankOccurred], a
.Wait
    halt
    ldh a, [VBlankOccurred]
    and a
    jr nz, .Wait
    ret

WaitFrames:
; Waits for c frames.
    call WaitFrame
    dec c
    jr nz, WaitFrames
    ret

EnsureVBlank:
    ld a, [STAT]
    bit 1, a
    ret z
    jr EnsureVBlank

;EnsureVBlank:
;; Returns immediately if in V-Blank, else returns once we're in it.
;    call CheckVBlank
;    ret nz
;;.CheckIfHBlankInterruptsAreEnabled
;;; TODO: Check if this is needed! This is unnecessary if H-Blank interrupts are always enabled.
;;    ld a, [STAT]
;;    bit 3, a
;;    jr z, EnsureVBlank
;;.Halt
;;; Wait until the H-Blank interrupt fires.
;;    halt
;.CheckAgain
;; Acts like a busy-wait loop if not using the interrupt.
;    jr EnsureVBlank

CheckVBlank:
; If a is non-zero, we're in V-Blank. If a is zero, we're not in V-Blank.
; Can also just check the z flag after this returns!
    ld a, [STAT]
    bit 1, a
    jr nz, .NotInVBlank
    ;and a, %11
    ;dec a
    ;jr z, .NotInVBlank
.InVBlank
    inc a ; returns 1 if in H-Blank, 2 if in V-Blank
    ret
.NotInVBlank
    xor a
    ret

SECTION "RNG Seed", HRAM
RNGSeed: dw

SECTION "Random Number Generator", ROM0
Random::
Xorshift::
; Generates an 8-bit psuedorandom number
; An 8-bit implementation of an xorshift PRNG with a period of 2^16 - 1
; Uses parameters a = 7, b = 6, c = 1 in the algorithm
    push bc
    ldh a, [RNGSeed + 1] ; x

; t ^= (t << 7)
    ld b, a
    rrca
    and %10000000
    xor a, b

; t ^= (t >> 6)
    ld b, a
    swap a
    rrca
    rrca
    and %00000011
    xor a, b

; x = y
    ld c, a
    ldh a, [RNGSeed] ; y
    ldh [RNGSeed + 1], a ; x = y

; y ^= (y >> 1)
    ld b, a
    srl a
    xor a, b

; y ^= t
    xor a, c
    ldh [RNGSeed], a ; y

    pop bc
    ret


SeedRNG::
; Expects a suitable seed in a, which is used for the 'x' byte
; The divider is used for the 'y' byte
    ldh [RNGSeed + 1], a
    ld a, [DIVI]
    ldh [RNGSeed], a
    ret


Rand:
; Generates a random number between 0-c.
; TODO: Write
    call Xorshift
    dec a
    ret


SECTION "Subroutines", ROM0

WordMultiply::
    ; Multiplies two 16-bit numbers.
    ; Returns the result in hl
    ; bc = operand 1; de = operand 2
    ; Destroys all registers in the process.
    ; Adapted from http://cpctech.cpc-live.com/docs/mult.html

    ld a, 16     ; Number of bits to process
    ld hl, 0     ; Holds the partial and final result

.Loop
    srl16 bc, 1 ; divides bc by 2
    ;; if carry = 0, then state of bit 0 was 0, (the rightmost digit was 0)
    ;; if carry = 1, then state of bit 1 was 1. (the rightmost digit was 1)
    ;; if rightmost digit was 0, then the result would be 0, and we do the add.
    ;; if rightmost digit was 1, then the result is DE and we do the add.
    jr nc, .NoAdd

    ;; will get to here if carry = 1
    add hl, de

.NoAdd
    ;; at this point BC has already been divided by 2

    sla16 de, 1
    ; TODO: Handle overflow

    ;; at this point DE has been multiplied by 2

    dec a
    jr nz, .Loop ; Continue processing the rest of the bits
    ret


Multiply::
    ; Multiplies two 8-bit numbers, stopping early if possible.
    ; Returns the result in hl
    ; a = operand 1; e = operand 2
    ; Only b is unaffected.
    ; Adapted from WordMultiply

    ld c, 8  ; No. of bits to process
    ld d, 0  ; Necessary for 16-bit addition
    ld hl, 0 ; Holds the partial and final result

.Loop
    or a
    ret z ; If we're done, return now!

    srl a ; Divides a by 2
    jr nc, .NoAdd

.Carry
    add hl, de

.NoAdd
    sla16 de, 1 ; Multiplies de by 2

    dec c
    jr nz, .Loop
    ret


SmallMultiply::
; Multiplies two 8-bit numbers, returning the result in an 8-bit number
; Uses less registers, and stops early if possible.
; Returns the result in a
; ? = operand 1; ? = operand 2
; Adapted from Multiply, which was adapted from WordMultiply

    ld d, 8 ; No. of bits to process
    xor a   ; Holds the result

.Loop
    srl b ; Divides b by 2
    ret z
    jr nc, .NoAdd

.Carry
    add a, c

.NoAdd
    sla c ; Multiplies c by 2
    ; TODO: Handle overflow

    dec c
    jr nz, .Loop
    ret


SECTION "Memory Copying", ROM0

MemCopyRoutine::
; Copies a memory region. Adpated from Jeff Frohwein's memory.asm
; hl = source, de = destination, bc = byte count
.loop
    ld a,[hl+]
	ld [de],a
	inc de

.skip
    dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

SmallMemCopyRoutine::
; hl = source, de = destination, b = byte count
.Loop
    ld a, [hl+]
    ld [de], a
    inc de

    dec b
    jr nz, .Loop
    ret

MemCopy: MACRO
; A wrapper for the MemCopyRoutine
; \1 = source, \2 = destination, \3 = byte count
    ld hl, \1
    ld de, \2

IF \3 == 0
    WARN "Invalid parameter: Bytes must be greater than 0."
ENDC

IF \3 > $FF
    ld bc, \3
    call MemCopyRoutine
ENDC

IF \3 < $100
    ld b, \3
    call SmallMemCopyRoutine
ENDC
    ENDM

MemCopyFixedDestRoutine::
.Loop
    call EnsureVBlank
    ld a, [hl+]
    ld [$FF00+c], a

    dec b
    jr nz, .Loop
    ret

MemCopyFixedDest: MACRO
; \1 = source, \2 = destination (fixed), \3 = byte count
    ld hl, \1
    ld c, (\2 & $FF)
    ld b, \3
    call MemCopyFixedDestRoutine
    ENDM

