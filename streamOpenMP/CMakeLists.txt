cmake_minimum_required(VERSION 3.9)

project(streamOpenMP C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release)

## adding the following lines while cleaning the code
MESSAGE( STATUS "CMAKE_C_COMPILER_ID: "         ${CMAKE_C_COMPILER_ID} )
if (CMAKE_C_COMPILER_ID STREQUAL "GNU" )
    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -Wextra -Wno-unused-result -Wno-unused-parameter -ftree-vectorize -fopt-info -ffast-math -mavx2 ")
    #set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -Wextra -Wno-unused-result -Wno-unused-parameter -ftree-vectorize -fopt-info -ffast-math ")
    #set(CMAKE_EXE_LINKER_FLAGS "-lm" )
elseif ( CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM" )
    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -fvectorize  -qopt-report-file=stderr -qopt-report=max  -xCORE-AVX2")
    #set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -qopt-report=3 -qopt-report-phase=vec -xCORE-AVX2")
    #set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Wall -qopt-report=3 -qopt-report-phase=vec ")
elseif ( CMAKE_C_COMPILER_ID STREQUAL "NVHPC" )
    set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Minform=inform  -Mnodepchk -Minfo=all -Mvect=simd ")
    #set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -Minform=inform  -Mnodepchk -Minfo=all -Mvect=simd -tp=px ")
endif ( )
## end of adding the following lines while cleaning the code

set (streamOpenMP "src/streamOpenMP.c")
find_package(OpenMP REQUIRED)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
add_executable(streamOpenMP ${streamOpenMP})
