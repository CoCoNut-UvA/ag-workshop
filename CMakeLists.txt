cmake_minimum_required(VERSION 3.13)

project(ag_demo VERSION 1.0 LANGUAGES C)

option(DISABLE_ASAN "Disable address sanitizer")

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

bison_target(AGParser src/scanparse/parser.y "${CMAKE_CURRENT_BINARY_DIR}/parser.c"
    DEFINES_FILE "${CMAKE_CURRENT_BINARY_DIR}/parser.h" VERBOSE)

flex_target(AGLexer src/scanparse/lexer.l "${CMAKE_CURRENT_BINARY_DIR}/lexer.c"
    DEFINES_FILE "${CMAKE_CURRENT_BINARY_DIR}/lexer.h")
ADD_FLEX_BISON_DEPENDENCY(AGLexer AGParser)


include(./coconut/coconut.cmake)

# NOTE: this is not recommended, for more info why see:
# https://cmake.org/cmake/help/v3.29/command/file.html#filesystem
file(GLOB EQUATION_SOURCES CONFIGURE_DEPENDS "src/equations/*.c")

# Whenever you add a file, add it here too.
add_executable(ag_demo ${FLEX_AGLexer_OUTPUTS} ${BISON_AGParser_OUTPUTS}
    src/main.c src/checkerror.c src/print/print.c src/scanparse/scanParse.c
    src/global/globals.c src/global/globals.h

    ${EQUATION_SOURCES}
)

target_compile_options(ag_demo PRIVATE
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-Wall -Wextra -pedantic -Wno-unused-function>
)

# Enable address sanitizer
if(NOT DISABLE_ASAN)
    target_compile_options(ag_demo PRIVATE
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:$<$<CONFIG:Debug>:-fsanitize=address>>
    )

    target_link_options(ag_demo PRIVATE
        $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:$<$<CONFIG:Debug>:-fsanitize=address>>
    )
endif()

coconut_target_generate(ag_demo "${CMAKE_CURRENT_LIST_DIR}/src/main.ccn" dynamic)
target_include_directories(ag_demo
    PUBLIC "${CMAKE_CURRENT_LIST_DIR}/src"
)

add_custom_target(dot
    dot -Tpng ccngen/ast.dot > ast.png
    COMMENT "Generate a png of your ast based on the generated dot diagram."
)
