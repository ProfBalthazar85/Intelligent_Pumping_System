;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WTCMD        EQU       10100000B                ; WRITE DATA COMMAND
RDCMD        EQU       10100001B                ; READ DATA COMMAND       

DP           EQU       5DH                      ; DELAY TIME TO CHECK PRESSURE  

RAMPINC      EQU       10                       ; GRASUALY RAMP UP ACCELERATION
RAMPDEC      EQU       10                       ; GRASUALY RAMP DOWN ACCELERATION
                                                ; (T=5*DP MILISECOND)
ENDFRE       EQU       0                        ; MINIMUM FREQUENCY OF VFD (0Hz=4mA=0Volts)
MINFRE       EQU       140                      ; MINIMUM FREQUENCY OF VFD (30Hz)
MAXFRE       EQU       255                      ; MAXIMUM FREQUENCY OF VFD (60Hz=20mA=5Volts)
FRESTEP      EQU       1                        ; DEC OR INC STEP OF FREQUENCY (0.24Hz)
                                                ; (F= (FRESTEP*60)/(MAXFRE - MINFRE)
EE           BIT       P1.2                     ; MICRO1 & MICRO2 CONNECTOR 

STARTB       BIT       P1.7                     ; START BIT

SDA          BIT       P1.0                     ; PIN 5 OF EEPROM
SCL          BIT       P1.1                     ; PIN 6 OF EEPROM 

DAC          EQU       P0

ADC          EQU       P3                       ; ADC0808 PORT
A0	     BIT       P2.0                     ; MULTIPLEXER CHANNEL ADDRESSING 
A1	     BIT       P2.1                     ; MULTIPLEXER CHANNEL ADDRESSING
A2	     BIT       P2.2                     ; MULTIPLEXER CHANNEL ADDRESSING
EOC	     BIT       P2.6                     ; END OF CONVERSION
ALE          BIT       P2.5                     ; ADDRESS LATCH ENABLE
OE	     BIT       P2.4                     ; OUPUT ENABLE
SC	     BIT       P2.3                     ; START CONVERSION

RESETVFD     BIT       P2.7                     ; RESET VFD

MOTOR1       BIT       P1.3                     ; MOTOR1 ON/OFF
MOTOR2       BIT       P1.4                     ; MOTOR2 ON/OFF
MOTOR3       BIT       P1.5                     ; MOTOR3 ON/OFF
MOTOR4       BIT       P1.6                     ; MOTOR4 ON/OFF


PIDINC       EQU       6FH                      ; PID CONTROL INCREASE
PIDDEC       EQU       6CH                      ; PID CONTROL DECREASE
PREVIOUS     EQU       6BH                      ; PREVIOUS PRESSURE
CURRENT      EQU       64H                      ; CURRENT PRESSURE
PROPOR       EQU       63H                      ; PROPORTIONAL
INTEG        EQU       5FH                      ; INTEGRAL
DERAVI       EQU       5EH                      ; DERIVATIVE

F1           EQU       5CH                      ; CURRENT PRESSURE FILTER1
F2           EQU       5BH                      ; CURRENT PRESSURE FILTER2
R8           EQU       5AH                      ; REGISTER
R9           EQU       49H                      ; REGISTER
R10          EQU       48H                      ; REGISTER
R11          EQU       47H                      ; REGISTER
R12          EQU       46H                      ; REGISTER

PREPRE       EQU       7AH                      ; PRESET PRESSURE
CURPRE       EQU       6DH                      ; CURRENT PRESSURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ORG       0
             USING     0                        ; USING REGISTER BANK 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RESETSYSTEM:
PRESETS:
             MOV       7FH, #RAMPDEC
             MOV       7BH, #RAMPINC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             CALL      RDWRSTART                ; THE START OF READING FROM MEMORY
NUM_DP:
             MOV       R4, #23                  ;
             CALL      RD1                      ;
             MOV       DP, A
INITPRESETPRES:                                 ; READ PRESET PRESSURE FROM EEPROM
             MOV       R4, #0
             CALL      RD1
             MOV       PREPRE, A
             CALL      RDWRSTOP                 ; THE END OF READING FROM MEMORY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INSETI:
SETTIMERS:
             MOV       79H, #0H 
             MOV       78H, #0H
SETREGISTERS:
             MOV       R0, #0H
             MOV       R1, #0H
             MOV       R2, #0H
             MOV       R3, #0H
             MOV       R4, #0H
             MOV       R5, #ENDFRE              ;LOAD REGISTER WITH MINIMUM VALUE OF FREQUENCY
             MOV       R6, #0H 
             MOV       R7, #0H
INITADC:                                        ; INITIALIZE A/D
             CLR       SC                       ; SC LOW
             CLR       ALE                      ; ALE LOW
             CLR       OE                       ; OE LOW
INITMOTORS:                                     ; SETTING PUMPING SYSTEM (MOTORS & VFD)
             SETB      MOTOR1                   ; TURN OFF THE MOTOR1
             CALL      DELAY4MSEC               ; MAKE A DELAY TIME FOR 0.01 SECOND
             SETB      MOTOR2                   ; TURN OFF THE MOTOR2
             CALL      DELAY4MSEC               ; MAKE A DELAY TIME FOR 0.01 SECOND
             SETB      MOTOR3                   ; TURN OFF THE MOTOR3
             CALL      DELAY4MSEC               ; MAKE A DELAY TIME FOR 0.01 SECOND
             SETB      MOTOR4                   ; TURN OFF THE MOTOR4
             CALL      DELAY4MSEC               ; MAKE A DELAY TIME FOR 0.01 SECOND
             MOV       DAC, #0                  ; SET THE FREQUENCY OF THE VFD ON MINIMUM VALUE
             CALL      DELAYPROTECTION          ; MAKE A DELAY TIME FOR THE PROTECTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STARTCHECK1:                                    ; CHECK FOR AUTOMAIC OR MANUAL START
             JNB        STARTB, STARTREG1       ; WAIT UNTIL START BIT IS HIGH
             JMP        STARTCHECK1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STARTREG1:
             CALL      CURRENTPRESSURE
             MOV       CURPRE, R7 
             CALL      CALCUPREVINI             ; PREVIOUS CALCULATION
STARTREG:                                       ; PRESSURE REGULATION IN PUMPING SYSTEM
             CALL      DELAYPRES                ; MAKE A DELAY TIME FOR 'DP' MILISECOND
             CALL      CURRENTPRES              ; READ CURRENT VALUE OF PRESSURE
             CALL      PRESETPRES               ; READ THE PRESET VALUE OF PRESSURE
             JMP       COMPAREPRES              ; COMPARING PRESSURES AND CHANGING FREQUENCY
CONTICHECK:
             JB        STARTB, INSETIDECFREQ    ; WAIT UNTIL START BIT IS HIGH
             JMP       STARTREG 
INSETIDECFREQ:
             CJNE      R5, #ENDFRE, DECREASE    ; CHECK FOR MINIMUM FREQUENCY
             CALL      DELAYVFD1                ; MAKE A DELAY TIME FOR 1 SECOND
             JMP       RESETSYSTEM
DECREASE:
             DEC       R5
             MOV       DAC, R5
             CALL      DELAY4MSEC               ; MAKE A DELAY TIME FOR 0.01 SECOND
             JMP       INSETIDECFREQ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CALCUPREVINI:
             CALL      CURRENTPRES
             CALL      PRESETPRES
COMPARPREVIOUS: 
             MOV       B, R7
             MOV       A, R6
             DIV       AB
             MOV       R6, A
             MOV       R7, B
             CJNE      R6, #1, CHECK0FRAPRE
             CJNE      R7, #0, CONJAMPINCPRE
             MOV       PREVIOUS, #0             ; THE PREVIOUS VALUE OF e(t)             
             RET
CHECK0FRAPRE:
             CJNE      R6, #0, CONJAMPINCPRE
             MOV       A, CURPRE
             SUBB      A, PREPRE
             MOV       PREVIOUS, A              ; THE PREVIOUS VALUE OF e(t) 
             RET
CONJAMPINCPRE:
             MOV       A, PREPRE
             SUBB      A, CURPRE
             MOV       PREVIOUS, A              ; THE PREVIOUS VALUE OF e(t)
             RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CURRENTPRES:                                    ; READ CURRENT PRESSURE FROM PRESSURE SENSOR
             MOV       R7, CURPRE 
	     RET


PRESETPRES:                                     ; READ PRESET PRESSURE FROM EEPROM
             MOV       R6, PREPRE
             RET


COMPAREPRES: 
             MOV       B, R7
             MOV       A, R6
             DIV       AB
             MOV       R6, A
             MOV       R7, B
             CJNE      R6, #1, CHECK0FRA
             CJNE      R7, #0, CONJAMPINC
             JMP       CONTICHECK
CHECK0FRA:
             CJNE      R6, #0, CONJAMPINC
             JMP       DECFREQUENCY
CONJAMPINC:
             JMP       INCFREQUENCY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INCFREQUENCY:
             CALL      INCCALPID
             CJNE      R5, #MAXFRE, INCFREQ2    ; CHECK FOR MAXIMUM FREQUENCY
             JMP       TURNONMOTOR              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INCFREQ2:
             INC       R5
             MOV       DAC, R5 
             CJNE      R5, #MAXFRE, INCFREQ3    ; CHECK FOR MAXIMUM FREQUENCY
             JMP       TURNONMOTOR 
INCFREQ3:
             DJNZ      PIDINC, AGAININC
             JMP       CONTICHECK
AGAININC:
             JMP       INCFREQ2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TURNONMOTOR:
             JB        MOTOR4, ONTHEMOTORS      ; IF MOTOR4 IS OFF, TURN ON THE MOTORS
             JMP       CONTICHECK             
ONTHEMOTORS:
             JB        MOTOR1, MOT1             ; IF MOTOR1 IS OFF, TURN ON MOTOR1
             JB        MOTOR2, MOT2             ; IF MOTOR2 IS OFF, TURN ON MOTOR2 
             JB        MOTOR3, MOT3             ; IF MOTOR3 IS OFF, TURN ON MOTOR2 
             CLR       MOTOR4                   ; TURN ON MOTOR4
             CALL      DELAYMOTOR             ; MAKE A DELAY TIME FOR 0.25 SECOND
DISINCMOTOR4:
             JMP       CONTICHECK

MOT1:
             CLR       MOTOR1                   ; TURN ON MOTOR1
             CALL      DELAYMOTOR             ; MAKE A DELAY TIME FOR 0.25 SECOND
             JMP       CONTICHECK

MOT2:
             CLR       MOTOR2                   ; TURN ON MOTOR2
             CALL      DELAYMOTOR             ; MAKE A DELAY TIME FOR 0.25 SECOND
             JMP       CONTICHECK

MOT3:
             CLR       MOTOR3                   ; TURN ON MOTOR3
             CALL      DELAYMOTOR             ; MAKE A DELAY TIME FOR 0.25 SECOND
             JMP       CONTICHECK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DECFREQUENCY:
             CALL      DECCALPID
             JNB       MOTOR1, LMOTOR12
             CJNE      R5, #ENDFRE, JMPDECFREQ21     ;CHECK FOR MINIMUM FREQUENCY
             JMP       CONTICHECK
JMPDECFREQ21:
             JMP       DECFREQ21             
LMOTOR12:             
             CJNE      R5, #MINFRE, JMPDECFREQ22     ;CHECK FOR MINIMUM FREQUENCY
             JMP       TURNOFFMOTOR
JMPDECFREQ22:
             JMP       DECFREQ22

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DECFREQ21:
             DEC       R5
             MOV       DAC, R5
             CJNE      R5, #ENDFRE, DECFREQ212       ;CHECK FOR MINIMUM FREQUENCY
             JMP       CONTICHECK
DECFREQ212:
             MOV       A, PIDDEC
             CJNE      A, #0, AGAINDEC1 
             JMP       CONTICHECK
AGAINDEC1:
             DJNZ      PIDDEC, AGAINDEC
             JMP       CONTICHECK
AGAINDEC:               
             JMP       DECFREQ21

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DECFREQ22:
             DEC       R5
             MOV       DAC, R5
             CJNE      R5, #MINFRE, DECFREQ221      ;CHECK FOR MINIMUM FREQUENCY
             JMP       TURNOFFMOTOR
DECFREQ221:
             MOV       A, PIDDEC
             CJNE      A, #0, OFFAGAINDEC1 
             JMP       CONTICHECK
OFFAGAINDEC1:
             DJNZ      PIDDEC, OFFAGAINDEC
             JMP       CONTICHECK
OFFAGAINDEC:
             JMP       DECFREQ22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TURNOFFMOTOR:
             JB        MOTOR1, JMPCONTICHECK
             JNB       MOTOR4, MOTO4            ; IF MOTOR4 IS OFF, TURN OFF MOTOR3
             JNB       MOTOR3, MOTO3            ; IF MOTOR3 IS OFF, TURN OFF MOTOR2
             JNB       MOTOR2, MOTO2            ; IF MOTOR2 IS OFF, TURN OFF MOTOR1
             SETB      MOTOR1                   ; TURN OFF MOTOR1
             CALL      DELAYMOTOR            ; MAKE A DELAY TIME FOR 0.1 SECOND
JMPCONTICHECK:
             JMP       CONTICHECK

MOTO2: 
             SETB      MOTOR2                   ; TURN OFF MOTOR2            
             CALL      DELAYMOTOR            ; MAKE A DELAY TIME FOR 0.1 SECOND
             JMP       CONTICHECK
MOTO3: 
             SETB      MOTOR3                   ; TURN OFF MOTOR3            
             CALL      DELAYMOTOR            ; MAKE A DELAY TIME FOR 0.1 SECOND
             JMP       CONTICHECK
MOTO4: 
             SETB      MOTOR4                   ; TURN OFF MOTOR4            
             CALL      DELAYMOTOR            ; MAKE A DELAY TIME FOR 0.1 SECOND
             JMP       CONTICHECK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
; PID ALGORITHMS (PROPORTIONAL-INTEGRAL-DERIVATIVE)
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INCCALPID:
INCPROPORTIONAL:
             MOV       A, PREPRE
             SUBB      A, CURPRE
             MOV       B, #3
             DIV       AB
             MOV       PROPOR, A                ; PROPORTIONAL
             CJNE      A, #0, INCDERIVATIVE
             MOV       A, B
             CJNE      A, #2, INCDERIVATIVE1
             MOV       PROPOR, #1               ; PROPORTIONAL
             JMP       INCDERIVATIVE
INCDERIVATIVE1:
             MOV       PROPOR, #1               ; PROPORTIONAL
INCDERIVATIVE:
             MOV       A, PREPRE
             SUBB      A, CURPRE
             MOV       CURRENT, A
             MOV       A, CURRENT
             SUBB      A, PREVIOUS
             MOV       B, #2                    ; D
             MUL       AB
             MOV       B, DP
             DIV       AB
             MOV       B, #50
             DIV       AB
             MOV       DERAVI, A
INCSUMOFPID:
             MOV       A, PROPOR
             ADD       A, DERAVI
             MOV       PIDINC, A
INCPREVIOUSCAL:
             MOV       A, PREPRE
             SUBB      A, CURPRE
             MOV       PREVIOUS, A              ; THE PREVIOUS VALUE OF e(t)
             RET           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DECCALPID:
DECPROPORTIONAL:
             MOV       A, CURPRE
             SUBB      A, PREPRE
             MOV       B, #3
             DIV       AB
             MOV       PROPOR, A                ; PROPORTIONAL
             CJNE      A, #0, DECDERIVATIVE
             MOV       A, B
             CJNE      A, #2, DECDERIVATIVE1
             MOV       PROPOR, #1               ; PROPORTIONAL
             JMP       INCDERIVATIVE
DECDERIVATIVE1:
             MOV       PROPOR, #1               ; PROPORTIONAL
DECDERIVATIVE:
             MOV       A, CURPRE
             SUBB      A, PREPRE
             MOV       CURRENT, A
             MOV       A, CURRENT
             SUBB      A, PREVIOUS
             MOV       B, #5                    ; D
             MUL       AB
             MOV       B, DP
             DIV       AB
             MOV       B, #4
             DIV       AB
             MOV       DERAVI, A
DECSUMOFPID:
             MOV       A, PROPOR
             ADD       A, DERAVI
             MOV       PIDDEC, A
DECPREVIOUSCAL:
             MOV       A, CURPRE
             SUBB      A, PREPRE
             MOV       PREVIOUS, A              ; THE PREVIOUS VALUE OF e(t) 
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
READADC:                                        ; A/D CONVERSION ROUTINE	
             SETB      ALE                      ; ALE HIGH
             NOP                                ; WAIT A LITTLE 
             NOP
             NOP
             NOP
	     SETB      SC                       ; SC HIGH
             NOP                                ; WAIT A LITTLE
             NOP
             NOP
	     CLR       ALE                      ; ALE LOW          
             NOP                                ; WAIT A LITTLE
             NOP
             NOP
	     CLR       SC                       ; SC LOW
             NOP                                ; WAIT A LITTLE
             NOP
DELAYHIGH:                                      ; MAKE A DELAY TIME
             MOV       A, #0
REPEAT:
             INC       A
             CJNE      A, #20, REPEAT
HERE2:
             JNB       EOC, HERE2               ; WAIT UNTIL EOC IS HIGH
	     SETB      OE                       ; OE HIGH
             NOP                                ; WAIT A LITTLE 
             NOP
             NOP
	     RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WR1:                                        ;EEPROM
             MOV       R1, A                         
             CALL      BYTEW
             RET

BYTEW:   
             MOV       A, #WTCMD               
             CALL      OUTS                        
             MOV       A, R4                         
             CALL      OUT                          
             MOV       A, R1                      
             CALL      OUT                         
             CALL      STOP                        
             RET

RD1:  
             CALL      BYTERD
             RET

BYTERD:   
             MOV       A, #WTCMD              
             CALL      OUTS                        
             MOV       A, R4                         
             CALL      OUT                           
             CALL      CREAD                       
             RET

CREAD:      
             MOV       A, #RDCMD             
             CALL      OUTS                      
             CALL      IN                            
             MOV       R1, A                       
             CALL      STOP                      
             RET

ACKTST:    
             MOV       A, #WTCMD             
             MOV       R2, #8                        
             CLR       SDA                           
             NOP                                         
             NOP
             NOP
             CLR       SCL                
AKTLP:   
             RLC       A                              
             JNC       AKTLS
             SETB      SDA                        
             JMP       AKTL1                
AKTLS:     
             CLR       SDA                        
AKTL1:     
             SETB      SCL                        
             NOP                                         
             NOP
             NOP
             NOP
             CLR       SCL                   
             DJNZ      R2, AKTLP             
             SETB      SDA                       
             NOP                                        
             SETB      SCL                       
             NOP                                        
             NOP
             NOP
             NOP
             JNB       SDA, EXIT                
             JMP       ACKTST                 
EXIT:       
             CLR       SCL                         
             CLR       SDA                          
             NOP                                         
             NOP
             NOP
             NOP
             SETB      SCL                        
             NOP
             NOP
             SETB      SDA                     
             RET

OUTS:       
             MOV       R2, #8                      
             SETB      SDA                       
             SETB      SCL                        
             NOP                                         
             NOP
             NOP
             NOP
             CLR       SDA                        
             NOP                                        
             NOP
             NOP
             NOP
             CLR       SCL                      
OTSLP:     
             RLC       A                           
             JNC       BITLS
             SETB      SDA                      
             JMP       OTSL1                  
BITLS:     
             CLR       SDA                      
OTSL1:      
             SETB      SCL                      
             NOP                                      
             NOP
             NOP
             NOP
             CLR       SCL                    
             DJNZ      R2, OTSLP          
             SETB      SDA                      
             NOP                                    
             NOP
             SETB      SCL                    
             NOP                                     
             NOP
             NOP
             NOP
             CLR       SCL
             RET

OUT:       
             MOV       R2, #8                     
OTLP:    
             RLC       A                           
             JNC       BITL
             SETB      SDA                      
             JMP       OTL1                     
BITL:      
             CLR       SDA                      
OTL1:    
             SETB      SCL                      
             NOP                                     
             NOP
             NOP
             NOP
             CLR       SCL                     
             DJNZ      R2, OTLP               
             SETB      SDA                      
             NOP                                    
             NOP
             SETB      SCL                    
             NOP                                   
             NOP
             NOP
             NOP
             CLR       SCL
             RET

IN:          MOV       R2, #8                
             SETB      SDA                  
INLP:       
             CLR       SCL                  
             NOP                                 
             NOP
             NOP
             NOP
             NOP
             SETB      SCL                  
             CLR       C                     
             JNB       SDA, INL1         
             CPL       C                        
INL1:       
             RLC       A                        
             DJNZ      R2, INLP             
             CLR       SCL                  
             RET
STOP:      
             CLR       SDA                  
             NOP                                    
             NOP
             NOP
             NOP
             SETB      SCL                   
             NOP                                    
             NOP
             NOP
             NOP
             SETB      SDA                   
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAYPRES:  
             MOV       R0, DP
             MOV       R8, #0H
             MOV       R9, #0H  
             MOV       R10, DP
             MOV       TMOD, #01H
SABNAPRES:   
             MOV       TH0, #HIGH(-5000)
             MOV       TL0, #LOW(-5000)
             SETB      TR0
WAITPRES:   
             JNB       TF0, WAITPRES
             CLR       TR0
             CLR       TF0
             CALL      PRESSURETRANSMITTER
             DJNZ      R0, SABNAPRES            ; 5DH = DP     
             RET

PRESSURETRANSMITTER:                            ; PUT THE CURRENT PRESSURE INTO MEMORY
             CALL      CURRENTPRESSURE
FILTERCUR:
             MOV       A, R7
             MOV       B, DP
             DIV       AB
             ADD       A, R8
             MOV       R8, A
             MOV       A, B
             ADD       A, R9
             MOV       R9, B
             DJNZ      R10, NEXTPRE
             MOV       B, DP
             MOV       A, R9
             DIV       AB
             ADD       A, R8
             MOV       F1, A
REMAINDERCA:
             MOV       B, #2
             MOV       A, DP
             DIV       AB
             MOV       F2, A
             MOV       A, R9
             CJNE      A, #F2, CHECKCARY1 
CHECKCARYBACK:
             MOV       A, F1
             ADD       A, #1
             JMP       FILCURPRE
CHECKCARY1:
             JC        NOADDING
             JMP       CHECKCARYBACK
FILCURPRE:             
             MOV       CURPRE, A
NEXTPRE:                   
             RET

NOADDING:
             MOV       CURPRE, F1
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAYPROTECTION:
             MOV       R0, #0H 
             MOV       79H, #0H 
             MOV       78H, #0H
             MOV       TMOD, #01H
SABNAPROTECTION:   
             MOV       TH0, #HIGH(-25000)
             MOV       TL0, #LOW(-25000)
             SETB      TR0
WAITPROTECTION:   
             JNB       TF0, WAITPROTECTION
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #40, SABNAPROTECTION ;1 SECOND
             MOV       R0, #0
             JNB       STARTB, CHECKDELPROTECT
             JMP       RESETSYSTEM              ;SYSTEM RESTART
CHECKDELPROTECT:
             INC       79H
             MOV       A, 79H
             CJNE      A, #1, SABNAPROTECTION   ;MINUTE
             MOV       79H, #0
             INC       78H
             MOV       A, 78H
             CJNE      A, #20, SABNAPROTECTION  ;MINUTES  
             MOV       78H, #0
             RET


DELAYVFD1:
             MOV       R0, #0H 
             MOV       TMOD, #01H
SABNAVFD1:   
             MOV       TH0, #HIGH(-25000)
             MOV       TL0, #LOW(-25000)
             SETB      TR0
WAITVFD1:   
             JNB       TF0, WAITVFD1
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #40, SABNAVFD1
             MOV       R0, #0H
             RET





DELAY4MSEC:
             MOV       R0, #0H 
             MOV       TMOD, #01H
SABNA4MSEC:   
             MOV       TH0, #HIGH(-10000)
             MOV       TL0, #LOW(-10000)
             SETB      TR0
WAIT4MSEC:   
             JNB       TF0, WAIT4MSEC
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #1, SABNA4MSEC
             MOV       R0, #0H
             RET


DELAY4MSECRES:
             MOV       R0, #0H 
             MOV       TMOD, #01H
SABNA4MSECRES:   
             MOV       TH0, #HIGH(-10000)
             MOV       TL0, #LOW(-10000)
             SETB      TR0
WAIT4MSECRES:   
             JNB       TF0, WAIT4MSECRES
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #10, SABNA4MSECRES
             MOV       R0, #0H
             RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAYMOTOR:
             MOV       R0, #0H 
             MOV       TMOD, #01H
SABNAMOTOROFF:   
             MOV       TH0, #HIGH(-25000)
             MOV       TL0, #LOW(-25000)
             SETB      TR0
WAITMOTOROFF:   
             JNB       TF0, WAITMOTOROFF
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #10, SABNAMOTOROFF
             MOV       R0, #0H
             RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CURRENTPRESSURE:                                ;READ THE CURRENT PRESSURE FROM THE PRESSURE TRANSMITTER
             CLR       A0                       ;SET ADC MULTIPLEXER CHANNEL0
	     CLR       A1                       ;
	     CLR       A2                       ;
	     CALL      READADC                  ;CALL A/D CONVERSION ROUTINE
             MOV       R7, ADC                  ;GET DATA
             NOP                                ;WAIT A LITTLE
	     CLR       OE                       ;OE LOW (DISABLE)
             NOP                                ;WAIT A LITTLE
             NOP                                ;
             NOP                                ;
	     RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RDWRSTART:                                  
             JNB       EE, RDWRSTART        ;WAIT UNTIL SDA IS BUSY 
             CLR       EE
             RET
RDWRSTOP:
             SETB      EE
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
END
