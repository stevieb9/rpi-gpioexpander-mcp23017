#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <errno.h>
#include <fcntl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "bit.h"

#define OUTPUT              0x00
#define INPUT               0x01

#define HIGH                0x01
#define LOW                 0x00

#define MCP23017_IODIRA     0x00
#define MCP23017_IODIRB     0x01

#define MCP23017_IOCON_A    0x0A
#define MCP23017_IOCON_B    0x0B

#define MCP23017_GPIOA      0x12
#define MCP23017_GPIOB      0x13

#define MCP23017_OUTPUT     0x00
#define MCP23017_INPUT      0x01

int getFd (int expanderAddr);
int getRegister (int fd, int reg);
int setRegister (int fd, int reg, int value, char* name);

int getRegisterBit (int fd, int reg, int bit);

void _establishI2C (int fd);
void _close (int fd);

int _pinBit (int pin){
    if (pin < 0 || pin > 15){
        croak("pin '%d' is out of bounds. Pins 0-15 are available\n");
    }

    // since we're dealing with a register per bank,
    // We need to know where in the double register to
    // look

    return pin < 8 ? pin : pin - 8;
}

bool readPin (int fd, int pin){
    int reg = pin < 8 ? reg = MCP23017_GPIOA : MCP23017_GPIOB;
    int bit = _pinBit(pin);

    printf("reg: 0x%x, bit: %d\n", reg, bit);

    return getRegisterBit(fd, reg, bit);
}

void writePin (int fd, int pin, bool state){
    int reg = pin < 8 ? reg = MCP23017_GPIOA : MCP23017_GPIOB;
    int bit = _pinBit(pin);
    int value;

    if (state == HIGH){
//        setRegisterBit
        value = bitOn(getRegister(fd, reg), bit);

    }
    else {
        value = bitOff(getRegister(fd, reg), bit);
    }
    setRegister(fd, reg, value, "writePin()");
}

void pinMode (int fd, int pin, int mode){
    int reg = pin < 8 ? (int) MCP23017_IODIRA : (int) MCP23017_IODIRB;
    int bit = _pinBit(pin);
    int value;

    if (mode == INPUT){
        value = bitOn(getRegister(fd, reg), bit);

    }
    else {
        value = bitOff(getRegister(fd, reg), bit);
    }

    printf("val: %d\n", value);
    setRegister(fd, reg, value, "pinMode()");
    printf("reg: %d\n", getRegister(fd, MCP23017_IODIRB));
}
int getFd (int expanderAddr){

    int fd;

    if ((fd = open("/dev/i2c-1", O_RDWR)) < 0) {
        close(fd);
        printf("Couldn't open the device: %s\n", strerror(errno));
        exit(-1);
    }

    if (ioctl(fd, I2C_SLAVE_FORCE, expanderAddr) < 0) {
        close(fd);
        printf(
                "Couldn't find device at addr %d: %s\n",
                expanderAddr,
                strerror(errno)
        );
        exit(-1);
    }

    _establishI2C(fd);

    return fd;
}

void _establishI2C (int fd){

    int buf[1] = { 0x00 };

    if (write(fd, buf, 1) != 1){
        close(fd);
        printf("Error: Received no ACK bit, couldn't establish connection!");
        exit(-1);
    }
}

void _close (int fd){
    close(fd);
}

int getRegister (int fd, int reg){

    int buf[1];
    buf[0] = reg;

    if ((write(fd, buf, 1)) != 1){
        close(fd);
        croak(
            "Could not write register pointer %d: %s\n",
            reg,
            strerror(errno)
        );
    }

    if ((read(fd, buf, 1)) != 1){
        close(fd);
        croak("Could not read register %d: %s\n", reg, strerror(errno));
    }

    printf("REG: %d\n", buf[0]);
    return (int) buf[0];
}

int getRegisterBit (int fd, int reg, int bit){
    int regData = getRegister(fd, (int) reg);

    return (int) bitGet((unsigned int) regData, bit, bit);
}

int getRegisterBits (int fd, int reg, int msb, int lsb){
    return (int) bitGet((unsigned int) getRegister(fd, (int) reg), msb, lsb);
}

int setRegister(int fd, int reg, int value, char* name){

    int buf[2] = {reg, value};

    printf("BUF: %d, %d, size: %d\n", buf[0], buf[1], sizeof(buf));
    if ((write(fd, buf, sizeof(buf))) != 2){
        close(fd);
        printf(
                "Could not write to the %s register: %s\n",
                name,
                //strerror(errno)
                "test"
        );
        exit(-1);
    }

    return 0;
}

void cleanup (int fd){

    for (int i = 0; i < 0x16; i++){
        if (i == MCP23017_IOCON_A || i == MCP23017_IOCON_B){
            // never do anything with the shared control registers
            continue;
        }
        if (i == MCP23017_IODIRA || i == MCP23017_IODIRB){
            // direction registers get set back to INPUT
            setRegister(fd, (int) i, (int) 0xFF, "IODIR");
            continue;
        }
        setRegister(fd, i, 0x00, "rest");
    }
}

MODULE = RPi::GPIOExpander::MCP23017  PACKAGE = RPi::GPIOExpander::MCP23017

PROTOTYPES: DISABLE


int
getFd (expanderAddr)
	int	expanderAddr

void
_establishI2C (fd)
	int	fd
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _establishI2C(fd);
        if (PL_markstack_ptr != temp) {
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY;
        }
        return;

void
_close (fd)
	int	fd
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _close(fd);
        if (PL_markstack_ptr != temp) {
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY;
        }
        return;

int
getRegister (fd, reg)
	int	fd
	int	reg

int
getRegisterBit (fd, reg, bit)
	int	fd
	int	reg
	int	bit

int
getRegisterBits (fd, reg, msb, lsb)
	int	fd
	int	reg
	int	msb
	int	lsb

int
setRegister (fd, reg, value, name)
	int	fd
	int	reg
	int	value
	char* name

int readPin (fd, pin)
    int fd
    int pin

void writePin (fd, pin, state)
    int fd
    int pin
    int state

void pinMode (fd, pin, mode)
    int fd
    int pin
    int mode

void
cleanup (fd)
	int	fd
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        cleanup(fd);
        if (PL_markstack_ptr != temp) {
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY;
        }
        return;

