cmake_minimum_required(VERSION 3.13.1)

project(app
        VERSION 0.1
        DESCRIPTION "Very nice FFI project!"
        LANGUAGES CXX)

set(CMAKE_C_STANDARD 14)
set(CMAKE_CXX_STANDARD 14)

# Target must be "app" to be consistent with Edge Impulse Make files.
add_library(app
            SHARED
            native_ei.cpp)

include_directories(ei_include)