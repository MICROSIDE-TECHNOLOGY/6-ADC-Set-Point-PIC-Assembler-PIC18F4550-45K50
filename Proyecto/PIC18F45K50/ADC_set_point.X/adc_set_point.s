/*******************************************************************************
Company:
Microside Technology Inc.
File Name:
adc_set_point.s
Product Revision  :  1
Device            :  X-TRAINER
Driver Version    :  1.0
*******************************************************************************/

/*******************************************************************************
Para usar el codigo con bootloader, configurar como lo indica MICROSIDE:
1) File->Project Properties->Conf:->pic-as Global Options->pic-as Linker
2) En el campo "Additional Options" agregar:
     -mrom=2000-7F00
*******************************************************************************/
    
;Indica que el codigo solo es compatible con el uC PIC18F45K50
PROCESSOR 18F45K50
    
; PIC18F45K50 Bits de configuracion

; CONFIG1L
  CONFIG  PLLSEL = PLL3X        ; PLL Selection (3x clock multiplier)
  CONFIG  CFGPLLEN = ON         ; PLL Enable Configuration bit (PLL Enabled)
  CONFIG  CPUDIV = NOCLKDIV     ; CPU System Clock Postscaler (CPU uses system clock (no divide))
  CONFIG  LS48MHZ = SYS48X8     ; Low Speed USB mode with 48 MHz system clock (System clock at 48 MHz, USB clock divider is set to 8)

; CONFIG1H
  CONFIG  FOSC = INTOSCIO       ; Oscillator Selection (Internal oscillator)
  CONFIG  PCLKEN = ON           ; Primary Oscillator Shutdown (Primary oscillator enabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  nPWRTEN = ON          ; Power-up Timer Enable (Power up timer enabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable (BOR enabled in hardware (SBOREN is ignored))
  CONFIG  BORV = 250            ; Brown-out Reset Voltage (BOR set to 2.5V nominal)
  CONFIG  nLPBOR = ON           ; Low-Power Brown-out Reset (Low-Power Brown-out Reset enabled)

; CONFIG2H
  CONFIG  WDTEN = OFF           ; Watchdog Timer Enable bits (WDT disabled in hardware (SWDTEN ignored))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscaler (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = RC1          ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as digital I/O on Reset)
  CONFIG  T3CMX = RC0           ; Timer3 Clock Input MUX bit (T3CKI function is on RC0)
  CONFIG  SDOMX = RB3           ; SDO Output MUX bit (SDO function is on RB3)
  CONFIG  MCLRE = ON            ; Master Clear Reset Pin Enable (MCLR pin enabled; RE3 input disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port Enable (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled)

; CONFIG5L
  CONFIG  CP0 = OFF             ; Block 0 Code Protect (Block 0 is not code-protected)
  CONFIG  CP1 = OFF             ; Block 1 Code Protect (Block 1 is not code-protected)
  CONFIG  CP2 = OFF             ; Block 2 Code Protect (Block 2 is not code-protected)
  CONFIG  CP3 = OFF             ; Block 3 Code Protect (Block 3 is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protect (Boot block is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protect (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Block 0 Write Protect (Block 0 (0800-1FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Block 1 Write Protect (Block 1 (2000-3FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Block 2 Write Protect (Block 2 (04000-5FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Block 3 Write Protect (Block 3 (06000-7FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Registers Write Protect (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protect (Boot block (0000-7FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protect (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Block 0 Table Read Protect (Block 0 is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Block 1 Table Read Protect (Block 1 is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Block 2 Table Read Protect (Block 2 is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Block 3 Table Read Protect (Block 3 is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protect (Boot block is not protected from table reads executed in other blocks)

;INCLUYE DIRECTIVAS DEL ENSAMBLADOR PIC-AS
#include <xc.inc>

;SECCION DE PROGRAMA EN EL BANCO ACCESS, ALMACENA VARIABLES
PSECT  udata_acs
VPOT:	    ;ETIQUETA PARA EL OBJETO EN RAM
    DS	2   ;RESERVA 2 BYTES DE DATOS
    
;VECTORES DE INTERRUPCION REMAPEADOS
PSECT interruptRemap, class=CODE, reloc=2, abs 
org 0x2008h
RETFIE
org 0x2018h
RETFIE

;SECCION DE PROGRAMA CONFIGURA ADC-CANAL 0    
PSECT setADC, class=CODE, reloc=2
SET_ADC:
    MOVLW   0x2F
    BANKSEL(ANSELA)
    MOVWF   ANSELA
    CLRF    CCP2CON
    CLRF    CCPR2L
    CLRF    CCPR2H
    CLRF    ADCON1
    MOVLW   0xBE
    MOVWF   ADCON2
    CLRF    ADRESL
    CLRF    ADRESH
    MOVLW   0x01
    MOVWF   ADCON0
    RETURN

;SECCION DE PROGRAMA OBTIENE VALOR ADC-CANAL 0 Y LO ALMACENA EN VPOT 
PSECT getADC, class=CODE, reloc=2
GET_ADC:
    MOVLW   0x03    ;MUEVE LITERAL A WREG
    BANKSEL(ADCON0) ;SELECCIONA EL BANCO DE ADCON0
    MOVWF   ADCON0  ;CONFIGURA ENTRADA ANALOGICA
ADC_DONE:
    NOP
    BTFSC   ADCON0,1;REVISA SI HA FINALIZADO CONVERSION ANALOGICA
    GOTO    ADC_DONE
    ;ADC CON RESOLUCION DE 10 BITS, DOS BYTES REQUERIDOS PARA ALMACENARLO
    MOVFF   ADRESH,VPOT	;BYTE MAS SIGNIFICATIVO (MSB)
    MOVFF   ADRESL,VPOT+1;BYTE MENOS SIGNIFICATIVO (LSB)
    RETURN
    
;PUNTO DE ENTRADA DEL PROGRAMA EN REINICIO, POSICION ABSOLUTA 0x2000h
PSECT resetVec,class=CODE,reloc=2, abs
org 0x2000h
resetVec:
    goto main

;SECCION DE PROGRAMA PRINCIPAL
PSECT code
main:
    MOVLW   0x70
    MOVWF   OSCCON  ;CONFIGURA OSCILADOR
    SETF    TRISA   ;PUERTO A SE CONFIGURA COMO ENTRADAS
    BCF	    TRISA,4 ;PUERTO RA4 COMO SALIDA
    CALL    SET_ADC ;CONFIGURA ADC-CANAL 0
loop:
    CALL    GET_ADC ;OBTIENE VALOR ADC-CANAL 0
    MOVLW   0x01    ;MUEVE LITERAL A WREG
    CPFSLT  VPOT,a  ;COMPARA MSB DE VPOT CON WREG
    GOTO    led_on
    BCF	    LATA,4  ;LIMPIA PIN RA4
    goto    loop
;BIFURCACION SI VPOT > 512 EN DECIMAL
led_on:
    BSF	    LATA,4  ;SE COLOCA PIN RA4
    goto loop
    
END resetVec