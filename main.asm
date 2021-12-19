;*******************************************************************************
; This stationery serves as the framework for a user application.
; For a more comprehensive program that demonstrates the more advanced
; functionality of this processor, please see the demonstration applications,
; located in the examples subdirectory of the 'Freescale CodeWarrior for HC08'
; program directory.
;*******************************************************************************

                    #Uses     qe32.inc

;*******************************************************************************
                    #RAM
;*******************************************************************************

parity              rmb       1

;*******************************************************************************
                    #ROM
;*******************************************************************************

data1               fcb       $42,$80,$c1,$03,$c4
data2               fcb       60,125,254,255
data3               fcb       $ba,$99,$55,$11,$ca,$dd,$fb,$c8

;*******************************************************************************

                    #spauto

Start               proc
                    @rsp                          ; initialize the stack pointer
                    cli                           ; enable interrupts

                    !...      insert your code here

                    ldhx      #data3
                    lda       #::data3
                    bsr       CheckParity
                    sta       parity

Loop@@              @cop
                    bra       Loop@@

;*******************************************************************************

                    #spauto

CheckParity         proc
                    psha      length@@
Loop@@              lda       ,x
                    bsr       ByteParity
                    sub       ,x
                    sec
                    bne       Done@@
                    aix       #1
                    dbnz      length@@,sp,Loop@@
Done@@              ais       #:ais
                    rts

;*******************************************************************************

                    #spauto

ByteParity          proc
                    pshhx
                    #ais
                    psha:2    num@@,2
                    tsx
                    ror       num@@,spx
                    eor       num@@,spx
                    ror       num@@,spx
                    eor       num@@,spx
                    ror:2     num@@,spx
                    eor       num@@,spx
                    rora
                    bcs       Ones@@
          ;--------------------------------------
                    rora:2
                    ora       #$bf
                    and       num@@+1,spx
                    sta       num@@+1,spx
                    bra       Cont@@
          ;--------------------------------------
Ones@@              rora:2
                    and       #$40
                    ora       num@@+1,spx
                    sta       num@@+1,spx
          ;--------------------------------------
Cont@@              sta       num@@,spx
                    ror:2     num@@,spx
                    eor       num@@,spx
                    ror       num@@,spx
                    eor       num@@,spx
                    ror       num@@,spx
                    eor       num@@,spx
                    coma
                    rora:2
                    bcc       Zeros@@
          ;--------------------------------------
                    rora
                    and       #$80
                    ora       num@@+1,spx
                    bra       Done@@
          ;--------------------------------------
Zeros@@             rora
                    ora       #$7f
                    and       num@@+1,spx
          ;--------------------------------------
Done@@              ais       #:ais
                    pulhx
                    rts

                    #sp
;*******************************************************************************
                    @vector   Vreset,Start
;*******************************************************************************
