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
PROCESSOR 18F4550
    
; PIC18F4550 Bits de configuracion

; CONFIG1L
  CONFIG  PLLDIV = 5            ; PLL Prescaler Selection bits (Divide by 5 (20 MHz oscillator input))
  CONFIG  CPUDIV = OSC2_PLL3    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /2][96 MHz PLL Src: /3])
  CONFIG  USBDIV = 2            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes from the 96 MHz PLL divided by 2)

; CONFIG1H
  CONFIG  FOSC = HSPLL_HS       ; Oscillator Selection bits (HS oscillator, PLL enabled (HSPLL))
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  BOR = SOFT            ; Brown-out Reset Enable bits (Brown-out Reset enabled and controlled by software (SBOREN is enabled))
  CONFIG  BORV = 1              ; Brown-out Reset Voltage bits (Setting 2 4.33V)
  CONFIG  VREGEN = ON           ; USB Voltage Regulator Enable bit (USB voltage regulator enabled)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)

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
    MOVLW   0x0E
    BANKSEL(ADCON1)
    MOVLW   ADCON1  ;CONFIGURA EL CANAL 0 COMO ANALOGICO
    MOVLW   0xBE
    MOVWF   ADCON2  ;CONFIGURA TIEMPO DE ADQUISICION ANALOGICO
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