
# Project M1 specifications


The code makes use of AES and DES implemetations from the follwing:
* [DES implementation](https://github.com/dhuertas/DES/blob/master/des.c)
* [AES implementation](https://github.com/openluopworld/aes_128/blob/master/aes.c)

The code provides an implementation of a decryption engine for the data which we pass. 
Both the DES and the AES takes in randomly generated keys (manually) and decrypts the data. I have monitored the data and verified the results using Real Term and AES/DES calculator.

The switch case statement used helps the machine to identify the function to implement; 0x10: None, 0x20: XOR; 0x30: DES, 0x40 AES.

Both the DES and the AES make use of 128 bit keys.

For the M1, The CubeIDE project is attached which has the UART setup as UART 2.

