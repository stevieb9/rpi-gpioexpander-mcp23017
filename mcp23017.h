//
// Created by spek on 04/06/18.
//

#ifndef RPI_GPIOEXPANDER_MCP23017_MCP23017_H
#define RPI_GPIOEXPANDER_MCP23017_MCP23017_H

#endif //RPI_GPIOEXPANDER_MCP23017_MCP23017_H

// setup functions

int GPIO_getFd (int expanderAddr);
void _establishI2C (int fd);

// register functions

void _checkRegisterReadOnly (uint8_t reg);
int GPIO_getRegister (int fd, int reg);
int GPIO_getRegisterBit (int fd, int reg, int bit);
int GPIO_getRegisterBits (int fd, int reg, int msb, int lsb);
int GPIO_setRegister (int fd, int reg, int value, char* name);

// pin functions

int _pinBit (int pin);
bool GPIO_readPin (int fd, int pin);
void GPIO_writePin (int fd, int pin, bool state);
void GPIO_pinMode (int fd, int pin, int mode);

// operational functions

void GPIO_clean (int fd);

