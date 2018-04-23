import time
import serial

ser = serial.serial_for_url('loop://', timeout=1)

# ser = serial.Serial(
#     port     = '/dev/ttyUSB1',	#Configurar con el puerto
#     baudrate = 9600,
#     parity   = serial.PARITY_NONE,
#     stopbits = serial.STOPBITS_ONE,
#     bytesize = serial.EIGHTBITS
# )

ser.isOpen()
ser.timeout=None
ser.flushInput() 
ser.flushOutput()

print(ser.timeout)

print 'Ingrese una serie de numeros (Ej. 1234) y presione Enter\n'
print 'Escriba "exit" para salir y presione Enter\n\n'

while 1 :
    ser.flushInput()
    ser.flushOutput()
    input = raw_input("ToSent: ")
    if (input == 'exit'):
        ser.close()
        exit()
    else:
        ser.write(input)
        time.sleep(2)
        out = ''
        #print "Info: ",ser.inWaiting()
        while ser.inWaiting() > 0:
            out += ser.read(1)
        if out != '':
            print ">> " + out
