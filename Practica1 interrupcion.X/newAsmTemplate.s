PROCESSOR 16F887
#include <xc.inc>
;configuración de los fuses
    CONFIG FOSC=INTRC_NOCLKOUT
    CONFIG WDTE=OFF
    CONFIG PWRTE=ON
    CONFIG MCLRE=OFF
    CONFIG CP=OFF
    CONFIG CPD=OFF
    CONFIG BOREN=OFF
    CONFIG IESO=OFF
    CONFIG FCMEN=OFF
    CONFIG LVP=OFF
    CONFIG DEBUG=ON
    
    
    CONFIG BOR4V=BOR40V
    CONFIG WRT=OFF
PSECT udata
tick:
    DS 1
counter:
    DS 1
counter2:
    DS 1
operador:
    DS 1
        
PSECT code
delay:
movlw 0xFF
movwf counter
counter_loop:
movlw 0xFF
movwf tick
tick_loop:
decfsz tick,f
goto tick_loop
decfsz counter,f
goto counter_loop
return
    
    
PSECT resetVec,class=CODE,delta=2
resetVec:
goto main
    
PSECT isr,class=CODE,delta=2
isr:
    btfss INTCON,1         ;evaluamos la bandera de la interrupcion
    retfie
    
    btfss PORTA,0          ;logica para prender-apagar el led cuando ocurre la interrupcion
    goto PRENDER_LED
    goto APAGAR_LED
    
    PRENDER_LED:           ;etiqueta para prender el led
    bcf INTCON,1
    movlw 0b11111111
    movwf PORTA
    retfie
    
    APAGAR_LED:            ;etiqueta para apagar el led
    bcf INTCON,1
    movlw 0b00000000
    movwf PORTA
    retfie
	
    
PSECT main,class=CODE,delta=2
main:
  BANKSEL OPTION_REG
  movlw 0b01000000
  movwf OPTION_REG
  BANKSEL WPUB
  movlw 0b11111111
  movwf WPUB   
  clrf INTCON             ;configuracion de las interrupciones
    movlw 0b11010000
    movwf INTCON
    
    
    BANKSEL OSCCON         ;configuracion del ocilador
    movlw 0b01110000
    movwf OSCCON
    
    BANKSEL ANSEL           ;desactivamos el convertidor analogico digital de PORTA
    movlw   0x00
    movwf   ANSEL
    BANKSEL ANSELH          ;desactivamos el convertidor analogico digital de PORTB
    movlw   0x00
    movwf   ANSELH   
    
    BANKSEL PORTA      ;ponemos a 0 PORTA,PORTB Y PORTD 
    clrf    PORTA
    BANKSEL PORTD
    clrf    PORTD
    BANKSEL PORTB
    clrf    PORTB
    
    BANKSEL TRISB      ;configuramos el puerto b como entrada para leer la interrupcion
    movlw   0XFF
    movwf   TRISB
    BANKSEL TRISA      ;configuramos el Puertoa como entrada
    clrf    TRISA
    BANKSEL TRISD      ;configuramos el puerto b como entrada
    clrf    TRISD
    

loop:
    BANKSEL PORTD    ;Bucle para que parpadee el led
    bsf PORTD,0
    call delay
    bcf PORTD,0
    call delay  
    goto loop
    END resetVec
