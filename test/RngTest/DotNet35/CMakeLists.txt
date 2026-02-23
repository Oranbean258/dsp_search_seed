cmake_minimum_required(VERSION 3.25.0)
project(DotNet35RandomTest)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options(/GS)
add_compile_options(/utf-8)
add_compile_options(/arch:AVX2)
add_compile_options(/fp:fast)
if (${CMAKE_BUILD_TYPE} MATCHES "Release")
    add_compile_options(/O2 /Oi /Ot /Gy)
    add_link_options(/OPT:REF /OPT:ICF)
    message(STATUS "Configuring for RELEASE build with AVX2")
else ()
    add_compile_options(/Zi /Od)
    message(STATUS "Configuring for DEBUG build")
endif ()

add_executable(rng_test main.cpp)

target_include_directories(rng_test PRIVATE "${CMAKE_CURRENT_LIST_DIR}/../../../cpp_source_code")

install(TARGETS rng_test DESTINATION .)
