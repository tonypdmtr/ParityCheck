;*******************************************************************
;* This stationery serves as the framework for a user application. *
;* For a more comprehensive program that demonstrates the more     *
;* advanced functionality of this processor, please see the        *
;* demonstration applications, located in the examples             *
;* subdirectory of the "Freescale CodeWarrior for HC08" program    *
;* directory.                                                      *
;*******************************************************************

; Include derivative-specific definitions
            INCLUDE 'derivative.inc'
            
;
; export symbols
;
            XDEF _Startup
            ABSENTRY _Startup

;
; variable/data section
;
            ORG    RAMStart         ; Insert your data definition here
parita: 	DS.B   1

;
; code section
;
            ORG    ROMStart
data1:		DC.B	$42, $80, $c1, $03, $c4
end1:
delka1:		EQU		end1-data1

data2:		DC.B	60, 125, 254, 255
end2:  
delka2:		EQU		end2-data2

data3:		DC.B	 $ba, $99, $55, $11, $ca, $dd, $fb, $c8
end3:  
delka3:		EQU		end3-data3

_Startup:
            LDHX   #RAMEnd+1        ; initialize the stack pointer
            TXS
            CLI			; enable interrupts

			
			;lda		#$c1
			;bsr		byteparity
            ; Insert your code here
  			
   			ldhx	#data3
   			lda		#delka3
            bsr		checkparity
            sta		parita
            NOP

mainLoop: 
            feed_watchdog
            BRA    mainLoop



checkparity:	

;	navr_adr_low 	<---SP+3
;	navr_adr.high	<---SP+2
;	delka			<---SP+1
;	<---SP

			psha		;delka
loop:		lda		,x
			bsr		byteparity
			;psha
			;lda		,x
			;cmp		1,sp
			sub		,x
			bne		error
			;pula
			aix		#1
			dbnz	1,sp,loop
			;lda		#0
			ais		#1
			rts
						
error:		;lda		#1
			;ais		#2
			ais		#1
			rts            
  
            
byteparity:	
;	delka			<---SP+5
;	navr_adr_low 	<---SP+4
;	navr_adr.high	<---SP+3
;	cislo			<---SP+2
;	cislo			<---SP+1	
;	<---SP

			psha
			psha
			ror		1,sp
			eor		1,sp
			ror		1,sp
			eor		1,sp
			ror		1,sp
			ror		1,sp
			eor		1,sp
			rora	
			bcs		ones
			rora		
			rora	
			ora		#$bf
			and		2,sp
			sta		2,sp
			bra		continue			
			
ones:		rora
			rora
			and		#$40
			ora		2,sp
			sta		2,sp
											
;	delka			<---SP+5
;	navr_adr_low 	<---SP+4
;	navr_adr.high	<---SP+3
;	cislo s bit6	<---SP+2
;	cislo 			<---SP+1
;	<---SP
			
continue:	sta		1,sp
			ror		1,sp
			ror		1,sp
			eor		1,sp
			ror		1,sp
			eor		1,sp
			ror		1,sp
			eor		1,sp
			coma
			rora
			rora
			bcc		zeroes
			rora								
			and		#$80
			ora		2,sp
			ais		#2
			rts
			
zeroes:		rora
			ora		#$7f
			and		2,sp
			ais		#2
			rts

;**************************************************************
;* spurious - Spurious Interrupt Service Routine.             *
;*             (unwanted interrupt)                           *
;**************************************************************

spurious:				; placed here so that security value
			NOP			; does not change all the time.
			RTI

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************

            ORG	$FFFA

			DC.W  spurious			;
			DC.W  spurious			; SWI
			DC.W  _Startup			; Reset
