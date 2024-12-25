cmake_minimum_required(VERSION 3.10)
project(epsiworld LANGUAGES ASM)

# Define the source and output files
set(SOURCE_FILE ${CMAKE_SOURCE_DIR}/src/epsiworld.asm)
set(OUTPUT_BINARY ${CMAKE_BINARY_DIR}/epsiworld.bin)

# Custom command to assemble the bootloader
add_custom_command(
        OUTPUT ${OUTPUT_BINARY}
        COMMAND fasm ${SOURCE_FILE} ${OUTPUT_BINARY}
        DEPENDS ${SOURCE_FILE}
        COMMENT "Assembling the bootloader with FASM"
        VERBATIM
)

# Custom target to make sure the binary gets built
add_custom_target(epsiworld ALL
        DEPENDS ${OUTPUT_BINARY}
        COMMENT "Building epsiworld bootloader"
)

# Install the final binary
install(FILES ${OUTPUT_BINARY} DESTINATION bin)
