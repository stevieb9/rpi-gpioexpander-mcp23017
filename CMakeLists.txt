cmake_minimum_required(VERSION 3.9)
project(rpi_gpioexpander_mcp23017)

set(CMAKE_CXX_STANDARD 11)

add_executable(rpi_gpioexpander_mcp23017
        prototype/initial.c
        test.c)
