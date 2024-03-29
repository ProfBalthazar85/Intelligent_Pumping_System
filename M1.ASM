;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WTCMD        EQU       10100000B                ;WRITE DATA COMMAND         
RDCMD        EQU       10100001B                ;READ DATA COMMAND         

EE           BIT       P1.2                     ;MICRO1 & MICRO2 CONNECTOR  

STARTB       BIT       P2.0                     ;START BIT

EN           BIT       P1.7                     ;PIN 6 OF LCD
RS           BIT       P1.6                     ;PIN 4 OF LCD
RW           BIT       P1.5                     ;PIN 5 OF LCD

SDA          BIT       P1.0                     ;PIN 5 OF EEPROM
SCL          BIT       P1.1                     ;PIN 6 OF EEPROM 

K0           BIT       P1.3                     ;R1 OF KEYBOARD
K1           BIT       P1.4                     ;R2 OF KEYBOARD
K2           BIT       P3.2                     ;R3 OF KEYBOARD
K3           BIT       P3.3                     ;R4 OF KEYBOARD
K4           BIT       P3.4                     ;C1 OF KEYBOARD
K5           BIT       P3.5                     ;C2 OF KEYBOARD
K6           BIT       P3.6                     ;C3 OF KEYBOARD 
K7           BIT       P3.7                     ;C4 OF KEYBOARD


ONMOTOR1     BIT       78H                      ; 11, ON/OFF MOTOR1
ONMOTOR2     BIT       79H                      ; 12, ON/OFF MOTOR2
ONMOTOR3     BIT       7AH                      ; 13, ON/OFF MOTOR3
ONMOTOR4     BIT       7BH                      ; 14, ON/OFF MOTOR4
THRL1        BIT       7CH                      ; 15, THERMAL RELAY1
THRL2        BIT       7DH                      ; 16, THERMAL RELAY2
THRL3        BIT       7EH                      ; 17, THERMAL RELAY3
THRL4        BIT       7FH                      ; 18, THERMAL RELAY4
MOTORS       EQU       70H                      ; 1, MOTORS' STATE
ERR          EQU       67H                      ; 2, ERROR STATUS
CURFRE       EQU       6EH                      ; 3, CURRENT FREQUENCY
CURPRE       EQU       6DH                      ; 4, CURRENT PRESSURE
PRESW        EQU       69H                      ; 5, PRESSURE SWITCH
RES2         EQU       62H                      ; 6, RESERVE 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             ORG       0
             USING     0                        ; USING REGISTER BANK 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INSETI:
             MOV       R0, #0H
             MOV       R1, #0H
             MOV       R2, #0H
             MOV       R3, #0H
             MOV       R4, #0H
             MOV       R5, #0H
             MOV       R5, #0H
             MOV       R7, #0H
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INSETI00: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INITIALLCD1:                                    ;INITIALIZE LCD AND PRESENT "ANSHAN AB"
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
INITIALLCD2:
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
PRESENTATION:
             CALL      ANSHANDIS
             JMP       MAIN11
ANSHANDIS:
             MOV       A, #'O' 
             LCALL     WRITE_TEXT
             MOV       A, #'s' 
             LCALL     WRITE_TEXT
             MOV       A, #'s' 
             LCALL     WRITE_TEXT
             MOV       A, #'r' 
             LCALL     WRITE_TEXT
             MOV       A, #'o' 
             LCALL     WRITE_TEXT
             MOV       A, #'o' 
             LCALL     WRITE_TEXT
             MOV       A, #'s' 
             LCALL     WRITE_TEXT
             MOV       A, #'h' 
             LCALL     WRITE_TEXT
             SETB      EN
             CLR       RS
             MOV       P0,#0C0h
             CLR       EN
             LCALL     WAIT_LCD
             MOV       A, #' ' 
             LCALL     WRITE_TEXT
             MOV       A, #'e'
             LCALL     WRITE_TEXT
             MOV       A, #'t' 
             LCALL     WRITE_TEXT
             MOV       A, #' ' 
             LCALL     WRITE_TEXT
             MOV       A, #'a' 
             LCALL     WRITE_TEXT
             MOV       A, #'l' 
             LCALL     WRITE_TEXT
             MOV       A, #'.' 
             LCALL     WRITE_TEXT
             MOV       A, #' ' 
             LCALL     WRITE_TEXT
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAIN00:                                   
             CLR       K0
             SETB      K1
             SETB      K2
             SETB      K3
NUM11:       JNB       K4, LABEL1
NUM21:       JNB       K5, LABEL2
NUM31:       JNB       K6, LABEL3
             JNB       K7, LABELRE
ROW21:       SETB      K0
             CLR       K1
             SETB      K2
             SETB      K3
NUM41:       JNB       K4, LABEL4
NUM51:       JNB       K5, LABEL5
NUM61:       JNB       K6, LABEL6
KSET1:       JNB       K7, LABELMO
ROW31:       SETB      K0
             SETB      K1
             CLR       K2
             SETB      K3
NUM71:       JNB       K4, LABEL7
NUM81:       JNB       K5, LABEL8
NUM91:       JNB       K6, LABEL9
ROW41:       SETB      K0
             SETB      K1
             SETB      K2
             CLR       K3
ENTER1:      JNB       K4, LABELSE
NUM01:       JNB       K5, LABEL0
             JNB       K6, LABELENA
             JMP       MAIN00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LABEL1:    
             LJMP      LABELA1
LABEL2:      
             LJMP      LABELA2
LABEL3:       
             LJMP      LABELA3
LABELRE:   
             LJMP      LABELARE
LABEL4:      
             LJMP      LABELA4 
LABEL5:    
             LJMP      LABELA5
LABEL6:   
             LJMP      LABELA6
LABELSE:
             LJMP      LABELASE
LABEL7: 
             LJMP      SEVEN7
LABEL8: 
             LJMP      LABELA8
LABEL9:
             LJMP      LABELA9
LABELMO: 
             LJMP      LABELAMO
LABELENA:
             LJMP      LABELEN1
LABEL0:
             LJMP      LABELA0 
LABELSTA: 
             LJMP      MAIN00
LABELSTO:
             LJMP      MAIN00        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RESETSYSTEM:
MAIN11:    
             CLR       K0
             SETB      K1
             SETB      K2
             SETB      K3
             JNB       K7, LABELRE
ROW22:       SETB      K0
             CLR       K1
             SETB      K2
             SETB      K3
KSET2:       JNB       K7, LABELMO
ROW32:       SETB      K0
             SETB      K1
             CLR       K2
             SETB      K3
MODE2:       JNB       K7, LABELSTA
ROW42:       SETB      K0
             SETB      K1
             SETB      K2
             CLR       K3
ENTER2:      JNB       K4, LABELSE
             JNB       K6, LABELENA
             JNB       K7, LABELSTO
STARTCHECK1:                                    ;CHECK FOR AUTOMAIC OR MANUAL START
             JB        STARTB, MAIN11           ;WAIT UNTIL START BIT IS HIGH
             JMP       LCDSWITCH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCDSWITCH:
             CALL      SWITCHDIS
             CALL      DELAYLCD
             CALL      LCDANSHANAB
             JMP       MAIN11

SWITCHDIS:
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             MOV       A, #' ' 
             LCALL     WRITE_TEXT
             MOV       A, #' ' 
             LCALL     WRITE_TEXT 
             MOV       A, #'A' 
             LCALL     WRITE_TEXT
             MOV       A, #'U' 
             LCALL     WRITE_TEXT
             MOV       A, #'T' 
             LCALL     WRITE_TEXT
             MOV       A, #'O' 
             LCALL     WRITE_TEXT
             MOV       A, #' ' 
             LCALL     WRITE_TEXT
             MOV       A, #' ' 
             LCALL     WRITE_TEXT
             RET

LCDANSHANAB:
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD 
             CALL      ANSHANDIS
             CALL      DELAYLCD
             RET

LCDEMPTY3:
             MOV       A, #' '
             LCALL     WRITE_TEXT
             MOV       A, #' '
             LCALL     WRITE_TEXT
             MOV       A, #' '
             LCALL     WRITE_TEXT
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAINMOD:
             CLR       K0
             SETB      K1
             SETB      K2
             SETB      K3
NUM1M:       JNB       K4, LABEL1M
NUM2M:       JNB       K5, LABEL2M
NUM3M:       JNB       K6, LABEL3M
ROW2M:       SETB      K0
             CLR       K1
             SETB      K2
             SETB      K3
NUM4M:       JNB       K4, LABEL4M
NUM5M:       JNB       K5, LABEL5M
NUM6M:       JNB       K6, LABEL6M
KSETM:       JNB       K7, LABELMOM
ROW3M:       SETB      K0
             SETB      K1
             CLR       K2
             SETB      K3
NUM7M:       JNB       K4, LABEL7M
NUM8M:       JNB       K5, LABEL8M
NUM9M:       JNB       K6, LABEL9M
ROW4M:       SETB      K0
             SETB      K1
             SETB      K2
             CLR       K3
ENTERM:      JNB       K4, LABELSEM
NUM0M:       JNB       K5, LABEL0M
             JMP       MAINMOD

LABEL1M:    
             LJMP      LABELA1M
LABEL2M:      
             LJMP      LABELA2M
LABEL3M:       
             LJMP      LABELA3M
LABEL4M:      
             LJMP      LABELA4M 
LABEL5M:    
             LJMP      LABELA5M
LABEL6M:   
             LJMP      LABELA6M
LABELSEM:
             LJMP      LABELASE
LABEL7M: 
             LJMP      SEVEN7M
LABEL8M: 
             LJMP      LABELA8M
LABEL9M:
             LJMP      LABELA9M
LABELMOM: 
             LJMP      LABELAMO
LABEL0M:
             LJMP      LABELA0M 



LABELA0M:
             
LABELA9M:
            
LABELA8M:

SEVEN7M:

LABELA6M:

LABELA5M:

LABELA4M:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LABELA3M:
             MOV       R3, #3
             CALL      LOADDA3
             CALL      DELAY00   
             JMP       MAIN11
LOADDA3: 
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             CALL      RDWRSTART
             MOV       R4, #23
             CALL      RD1
             CALL      RDWRSTOP
             CALL      DIVER
             ADD       A, #48
             LCALL     WRITE_TEXT
             MOV       A, B
             ADD       A, #48
             LCALL     WRITE_TEXT
             RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;             
LABELA2M:
             MOV       R3, #2
             CALL      LOADDA2
             CALL      DELAY00   
             JMP       MAIN11
LOADDA2: 
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             CALL      RDWRSTART
             MOV       R4, #22
             CALL      RD1
             CALL      RDWRSTOP
             CALL      DIVER
             ADD       A, #48
             LCALL     WRITE_TEXT
             MOV       A, B
             ADD       A, #48
             LCALL     WRITE_TEXT
             RET
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;            
LABELA1M:
             MOV       R3, #1
             CALL      LOADDA1
             CALL      DELAY00   
             JMP       MAIN11
LOADDA1: 
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             CALL      RDWRSTART
             MOV       R4, #13
             CALL      RD1
             CALL      RDWRSTOP
             CALL      DIVER
             ADD       A, #48
             LCALL     WRITE_TEXT
             MOV       A, B
             ADD       A, #48
             LCALL     WRITE_TEXT
             RET
DIVER:   
             MOV       B, #10
             DIV       AB
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                
ENDOFDIGIT:
             LCALL     WRITE_TEXT
             CALL      DELAY00
             JMP       MAIN11
MIDOFDIGIT:
             CALL      DELAY00
             JMP       MAIN00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LABELA1:                                        ;
             INC       R7
             CJNE      R7, #1, TWO1
MON1:    
             MOV       A, #'1'
             LCALL     WRITE_TEXT
             MOV       R5, #1
             JMP       MIDOFDIGIT
TWO1:    
             MOV       B, #1
             MOV       A, #'1'
             JMP       ENDOFDIGIT

             

                                                
LABELA2:                                        ;
             INC       R7
             CJNE      R7, #1, TWO2 
MON2:    
             MOV       A, #'2'
             LCALL     WRITE_TEXT
             MOV       R5, #2
             JMP       MIDOFDIGIT
TWO2:    
             MOV       B, #2
             MOV       A, #'2'
             JMP       ENDOFDIGIT


                                               
                                                
LABELA3:                                        ;DIGIT 3 
             INC       R7
             CJNE      R7, #1, TWO3 
MON3:     
             MOV       A, #'3'
             LCALL     WRITE_TEXT
             MOV       R5, #3
             JMP       MIDOFDIGIT
TWO3: 
             MOV       B, #3
             MOV       A, #'3'
             JMP       ENDOFDIGIT
                                                

LABELARE:                                       ;RESTART KEY
             CALL      DELAY00
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             MOV       R7, #0 
             JMP       MIDOFDIGIT
                                                

LABELA4:                                        ;DIGIT 4  
             INC       R7
             CJNE      R7, #1, TWO4 
MON4:    
             MOV       A, #'4'
             LCALL     WRITE_TEXT
             MOV       R5, #4
             JMP       MIDOFDIGIT
TWO4:  
             MOV       B, #4
             MOV       A, #'4'
             JMP       ENDOFDIGIT
                                                

LABELA5:                                        ;DIGIT 5                                    
             INC       R7
             CJNE      R7, #1, TWO5 
MON5:   
             MOV       A, #'5'
             LCALL     WRITE_TEXT
             MOV       R5, #5
             JMP       MIDOFDIGIT
TWO5:   
             MOV       B, #5
             MOV       A, #'5'
             JMP       ENDOFDIGIT
                                             

LABELA6:                                        ;DIGIT6
             INC       R7
             CJNE      R7, #1, TWO6 
MON6:    
             MOV       A, #'6'
             LCALL     WRITE_TEXT
             MOV       R5, #6
             JMP       MIDOFDIGIT
TWO6:   
             MOV       B, #6
             MOV       A, #'6'
             JMP       ENDOFDIGIT

                                                
LABELASE:                                       ;SETTING KEY
             CALL      DELAY00
             LJMP      INSETI


SEVEN7:   
             INC       R7
             CJNE      R7, #1, TWO7 
MON7:  
             MOV       A, #'7'
             LCALL     WRITE_TEXT
             MOV       R5, #7
             JMP       MIDOFDIGIT
TWO7:    
             MOV       B, #7
             MOV       A, #'7'
             JMP       ENDOFDIGIT

                                                
LABELA8:                                        ;DIGIT 8 
             INC       R7
             CJNE      R7, #1, TWO8 
MON8:     
             MOV       A, #'8'
             LCALL     WRITE_TEXT
             MOV       R5, #8
             JMP       MIDOFDIGIT
TWO8:    
             MOV       B, #8
             MOV       A, #'8'
             JMP       ENDOFDIGIT
                                                

LABELA9:                                        ;DIGIT 9
             INC       R7
             CJNE      R7, #1, TWO9 
MON9:   
             MOV       A, #9
             ADD       A, #48
             LCALL     WRITE_TEXT
             MOV       R5, #9
             JMP       MIDOFDIGIT
TWO9:  
             MOV       B, #9
             MOV       A, #9
             ADD       A, #48
             JMP       ENDOFDIGIT



LABELA0:                                        ;DIGIT 0
             INC       R7
             CJNE      R7, #1, TWO0 
MON0:    
             MOV       A, #'0'
             LCALL     WRITE_TEXT
             MOV       R5, #0
             JMP       MIDOFDIGIT
TWO0:   
             MOV       B, #0
             MOV       A, #'0'
             JMP       ENDOFDIGIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LABELAMO:                                       ;MODE KEY
             JMP       MODE12

MODE12:                                         ;PRESENTATION "1=PPress, 2=PTRang, 3=DP" 
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             MOV       A, #'M'
             LCALL     WRITE_TEXT
             MOV       A, #'O'
             LCALL     WRITE_TEXT
             MOV       A, #'D'
             LCALL     WRITE_TEXT
             MOV       A, #':'
             LCALL     WRITE_TEXT
             CALL      LCDEMPTY3
             SETB      EN
             CLR       RS
             MOV       P0,#0C0h
             CLR       EN
             LCALL     WAIT_LCD
             MOV       A, #'1'
             LCALL     WRITE_TEXT
             MOV       A, #' '
             LCALL     WRITE_TEXT
             MOV       A, #'2'
             LCALL     WRITE_TEXT
             MOV       A, #' '
             LCALL     WRITE_TEXT
             MOV       A, #'3'
             LCALL     WRITE_TEXT
             CALL      LCDEMPTY3
             CALL      DELAY00
             JMP       MAINMOD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LABELEN1:                                       ;SAVING DATA 
             CJNE      R3, #1, NOM2
             JMP       NOMB1
NOM2:      
             CJNE      R3, #2, NOM3
             JMP       NOMB2
NOM3:
             CJNE      R3, #3, NOM4
             JMP       NOMB3
NOM4:
             CALL      DELAY00
             JMP       INSETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOMB1:                                          ;SAVING PRESET PRESSURE (MAXIMUM_PRESSURE=0.93MAX_PRESSURE TRANSMITTER RANGE meter H2o)
             CJNE      R7, #0, R7CHECK1
             CALL      DELAY00
             JMP       INSETI             
R7CHECK1:             
             CJNE      R7, #1, MUADDJUMPA
             MOV       A, R5
CONTIA:
             CALL      RDWRSTART
             MOV       R4, #13
             CALL      WR1
             CALL      ACKTST
             CALL      RDWRSTOP
             CALL      CONVERSION
             CALL      RDWRSTART
             MOV       R4, #0
             CALL      WR1
             CALL      ACKTST
             CALL      RDWRSTOP 
             CALL      THANKYOU
             CALL      DELAY00
             CALL      DELAY00
             CALL      DELAY00
             JMP       INSETI
MUADDJUMPA:
             JMP       MUADDA
MUADDA:   
             MOV       R6, B
             MOV       B, #10
             MOV       A, R5
             MUL       AB
             ADD       A, R6
             JMP       CONTIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOMB2:                                          ;SAVING PTMR (PRESSURE TRANSMITTER RANGE)
             CJNE      R7, #0, R7CHECK2
             CALL      DELAY00
             JMP       INSETI             
R7CHECK2:             
             CJNE      R7, #1, MUADDJUMPB
             MOV       A, R5
CONTIB:
             CALL      RDWRSTART
             MOV       R4, #22
             CALL      WR1
             CALL      ACKTST
             CALL      RDWRSTOP
             CALL      THANKYOU
             CALL      DELAY00
             CALL      DELAY00
             CALL      DELAY00
             JMP       INSETI
MUADDJUMPB:
             JMP       MUADDB
MUADDB:   
             MOV       R6, B
             MOV       B, #10
             MOV       A, R5
             MUL       AB
             ADD       A, R6
             JMP       CONTIB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOMB3:                                          ;SAVING DP (DELAY TIME FOR CHECKING PRESSURE)
             CJNE      R7, #0, R7CHECK3
             CALL      DELAY00
             JMP       INSETI             
R7CHECK3:             
             CJNE      R7, #1, MUADDJUMPC
             MOV       A, R5
CONTIC:
             CALL      RDWRSTART
             MOV       R4, #23
             CALL      WR1
             CALL      ACKTST
             CALL      RDWRSTOP
             CALL      THANKYOU
             CALL      DELAY00
             CALL      DELAY00
             CALL      DELAY00
             JMP       INSETI
MUADDJUMPC:
             JMP       MUADDC
MUADDC:   
             MOV       R6, B
             MOV       B, #10
             MOV       A, R5
             MUL       AB
             ADD       A, R6
             JMP       CONTIC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CONVERSION:                                     ;Y= [P_MAX(225/MAX_PTR) + 51], 
                                                ;(P= 0-(0.93MAX_PTR),R=270R ,m H2o, Y= 51-253)  
STEP01:
             CALL      RDWRSTART                
             MOV       R4, #22                  ;MAXIMUM PRESSURE TRANSMITTER RANGE
             CALL      RD1                  ;
             CALL      RDWRSTOP                 ;
STEP02:                                         ;(225/MAX_PTR)
             MOV       R0, A                    
             MOV       B, A
             MOV       A, #225
             DIV       AB
             MOV       7FH, A
             MOV       R1, B
             MOV       A, R0
             MOV       B, #10
             DIV       AB
             MOV       R2, A
             MOV       B, A
             MOV       A, R1
             DIV       AB
             MOV       7EH, A
STEP1:       
             MOV       B, 7FH                   ;
             MOV       A, R5                    ;MOVE P_MAX IN ACCUMULATOR
             MUL       AB
             MOV       B, #10
             DIV       AB
             MOV       R0, A                    
             MOV       R1, B                    
STEP2:
             MOV       B, 7FH                   ;
             MOV       A, R6
             MUL       AB
             MOV       B, #10
             DIV       AB
             MOV       R2, A                    
             MOV       R3, B                    
STEP3:
             MOV       B, 7EH                   ;
             MOV       A, R5
             MUL       AB
             MOV       B, #10
             DIV       AB
             MOV       R4, A                    
             MOV       R7, B                    
STEP4:
             MOV       B, 7EH                   ;
             MOV       A, R6
             MUL       AB
             MOV       B, #10
             DIV       AB
STEP5:
             MOV       B, R7
             ADD       A, B
             MOV       B, R3
             ADD       A, B
             MOV       B, #10
             DIV       AB
             MOV       R7, B                    ;
STEP6:
             MOV       B, R4
             ADD       A, B
             MOV       B, R2
             ADD       A, B
             MOV       B, R1
             ADD       A, B
             MOV       B, #10
             DIV       AB
             MOV       R4, B                    ;
STEP7:
             MOV       B, R0
             ADD       A, B
STEP8:
             MOV       B, #100
             MUL       AB
             MOV       R3, A                    ;
STEP9:
             MOV       B, #10
             MOV       A, R4
             MUL       AB
STEP10:
             MOV       B, R7
             ADD       A, B
             MOV       B, R3
             ADD       A, B
STEP11:
             MOV       B, #51
             ADD       A, B
             RET             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                       
THANKYOU:                                       ;PRESENTATION "THANK YOU"
             LCALL     INIT_LCD
             LCALL     CLEAR_LCD
             MOV       A, #'T'
             LCALL     WRITE_TEXT
             MOV       A, #'H'
             LCALL     WRITE_TEXT
             MOV       A, #'A'
             LCALL     WRITE_TEXT
             MOV       A, #'N'
             LCALL     WRITE_TEXT
             MOV       A, #'K'
             LCALL     WRITE_TEXT
             MOV       A, #'S'
             LCALL     WRITE_TEXT
             MOV       A, #'!'
             LCALL     WRITE_TEXT
             RET  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_LCD:                                       ;INITIALIZE LCD
             SETB      EN
             CLR       RS
             MOV       P0, #38h
             CLR       EN
             LCALL     WAIT_LCD
             SETB      EN
             CLR       RS
             MOV       P0, #0Eh
             CLR       EN
             LCALL     WAIT_LCD
             SETB      EN
             CLR       RS
             MOV       P0, #06h
             CLR       EN
             LCALL     WAIT_LCD
             RET
WAIT_LCD:
             SETB      EN                       
             CLR       RS                             
             SETB      RW                           
             MOV       P0, #0FFh                 
             MOV       A,P0                         
             JB        ACC.7, WAIT_LCD   
             CLR       EN                            
             CLR       RW                          
             RET

CLEAR_LCD:
             SETB      EN
             CLR       RS
             MOV       P0, #01h
             CLR       EN
             LCALL     WAIT_LCD
             RET

WRITE_TEXT:
             SETB      EN
             SETB      RS
             MOV       P0, A
             CLR       EN
             LCALL     WAIT_LCD
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DELAY00:                                         ;DELAY TIME       
             MOV       R0, #0H 
             MOV       TMOD, #01H
SABNA00:   
             MOV       TH0, #HIGH(-25000)
             MOV       TL0, #LOW(-25000)
             SETB      TR0
WAIT00:   
             JNB       TF0, WAIT00
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #20, SABNA00
             MOV       R0, #0H
             RET



DELAYLCD:
             MOV       R0, #0H 
             MOV       R1, #0H 
             MOV       TMOD, #01H
SABNALCD:   
             MOV       TH0, #HIGH(-25000)
             MOV       TL0, #LOW(-25000)
             SETB      TR0
WAITLCD:   
             JNB       TF0, WAITLCD
             CLR       TR0
             CLR       TF0
             INC       R0
             CJNE      R0, #40, SABNALCD        ;1 SECOND
             MOV       R0, #0H
             INC       R1
             CJNE      R1, #3, SABNALCD         ;3 SECOND
             MOV       R1, #0
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RDWRSTART:                                  
             JNB       EE, RDWRSTART        ;WAIT UNTIL SDA IS BUSY 
             CLR       EE
             RET
RDWRSTOP:
             SETB      EE
             RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
END
