#include <Arduino.h>
#include <ctype.h>
#include <stdarg.h>

#define bit9600Delay     84  
#define halfBit9600Delay 42
#define bit4800Delay     188 
#define halfBit4800Delay 94

byte rx_pin = 7;
byte tx_pin = 6;
byte SWval;

void setup() {
	pinMode(rx_pin, INPUT);
	pinMode(tx_pin, OUTPUT);

	digitalWrite(tx_pin,HIGH);

	Serial.begin(9600);
}

void SWprint(int data)
{
	byte mask;

	//startbit
	digitalWrite(tx_pin,LOW);

	delayMicroseconds(bit9600Delay);

	for (mask = 0x01; mask>0; mask <<= 1) {
		if (data & mask){ // choose bit
			digitalWrite(tx_pin, HIGH); // send 1
		}
		else{
			digitalWrite(tx_pin, LOW); // send 0
		}
		delayMicroseconds(bit9600Delay);
	}

	//stop bit

	digitalWrite(tx_pin, HIGH);
	delayMicroseconds(bit9600Delay);
}



int SWread()
{
	byte val = 0;

	while (digitalRead(rx_pin));
	//wait for start bit

	if (digitalRead(rx_pin) == LOW) {

		delayMicroseconds(halfBit9600Delay);

		for (int offset = 0; offset < 8; offset++) {
			delayMicroseconds(bit9600Delay);
			val |= digitalRead(rx_pin) << offset;
		}

		//wait for stop bit + extra
		delayMicroseconds(bit9600Delay); 
		delayMicroseconds(bit9600Delay);

		return val;
	}

	return 0;
}

void p(char *fmt, ... ){
        char tmp[128]; // resulting string limited to 128 chars
        va_list args;
        va_start (args, fmt );
        vsnprintf(tmp, 128, fmt, args);
        va_end (args);
        Serial.print(tmp);
}

void loop() {
	//Serial.print("Hello\n");
	
	SWval = toupper(SWread());

	if (SWval == 'A') {
		Serial.print("FOUND\n");
	}

	p("[%d]\n", ((int) SWval));
	SWprint(128);

	delay(1000);
}
