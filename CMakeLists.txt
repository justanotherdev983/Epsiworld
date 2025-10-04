cmake_minimum_required(VERSION 3.10)
project(epsiworld LANGUAGES ASM CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Define source directories and files
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)
set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
set(BOOTLOADER_SOURCE ${SRC_DIR}/boot/bootloader.asm)
set(KERNEL_ENTRY_SOURCE ${SRC_DIR}/boot/kernel_entry.asm)
set(KERNEL_CPP_SOURCE ${SRC_DIR}/kernel/kernel.cpp)
set(MEMORY_CPP_SOURCE ${SRC_DIR}/libc/memory.cpp)
set(KEYBOARD_CPP_SOURCE ${SRC_DIR}/drivers/keyboard.cpp)
set(TERMINAL_CPP_SOURCE ${SRC_DIR}/drivers/terminal.cpp)
set(IO_ASM_SOURCE ${SRC_DIR}/util/io.asm)

# Define output files
set(BOOTLOADER_BINARY ${CMAKE_BINARY_DIR}/bootloader.bin)
set(KERNEL_ENTRY_BINARY ${CMAKE_BINARY_DIR}/kernel_entry.o)
set(IO_BINARY ${CMAKE_BINARY_DIR}/io.o)
set(KERNEL_LINKED ${CMAKE_BINARY_DIR}/kernel_linked.bin)
set(DISK_IMAGE ${CMAKE_BINARY_DIR}/disk.img)

# Create directories if they don't exist
file(MAKE_DIRECTORY ${SRC_DIR})
file(MAKE_DIRECTORY ${INCLUDE_DIR})

# Generate linker script for kernel
file(WRITE ${CMAKE_BINARY_DIR}/linker.ld
"ENTRY(kernel_entry)
SECTIONS {
    . = 0x10000;
    .text : {
        *(.text)
    }
    .rodata : {
        *(.rodata)
    }
    .data : {
        *(.data)
    }
    .bss : {
        *(COMMON)
        *(.bss)
    }
}
")

# Assemble kernel_entry.asm to ELF object file
add_custom_command(
    OUTPUT ${KERNEL_ENTRY_BINARY}
    COMMAND fasm ${KERNEL_ENTRY_SOURCE} ${KERNEL_ENTRY_BINARY}
    DEPENDS ${KERNEL_ENTRY_SOURCE}
    COMMENT "Assembling kernel_entry.asm with FASM"
    VERBATIM
)

# Assemble io.asm to ELF object file
add_custom_command(
    OUTPUT ${IO_BINARY}
    COMMAND fasm ${IO_ASM_SOURCE} ${IO_BINARY}
    DEPENDS ${IO_ASM_SOURCE}
    COMMENT "Assembling io.asm with FASM"
    VERBATIM
)

# Compile bootloader using FASM
add_custom_command(
    OUTPUT ${BOOTLOADER_BINARY}
    COMMAND fasm ${BOOTLOADER_SOURCE} ${BOOTLOADER_BINARY}
    DEPENDS ${BOOTLOADER_SOURCE}
    COMMENT "Assembling the bootloader with FASM"
    VERBATIM
)

# Set up C++ compiler for OS development
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32 -ffreestanding -fno-exceptions -fno-rtti -nostdlib -nostdinc++ -Wall -Wextra")

# Add library target for kernel files
add_library(kernel_obj OBJECT ${KERNEL_CPP_SOURCE} ${MEMORY_CPP_SOURCE} ${KEYBOARD_CPP_SOURCE} ${TERMINAL_CPP_SOURCE})
target_include_directories(kernel_obj PRIVATE ${INCLUDE_DIR})

# Create a custom target that depends on kernel_obj and links everything
add_custom_command(
    OUTPUT ${KERNEL_LINKED}
    COMMAND ld -m elf_i386 -T ${CMAKE_BINARY_DIR}/linker.ld -o ${KERNEL_LINKED}
            ${KERNEL_ENTRY_BINARY}
            ${IO_BINARY}
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/kernel/kernel.cpp.o
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/libc/memory.cpp.o
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/drivers/terminal.cpp.o
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/drivers/keyboard.cpp.o
    DEPENDS ${KERNEL_ENTRY_BINARY} ${IO_BINARY} kernel_obj ${CMAKE_BINARY_DIR}/linker.ld
            ${KERNEL_CPP_SOURCE} ${MEMORY_CPP_SOURCE} ${KEYBOARD_CPP_SOURCE} ${TERMINAL_CPP_SOURCE}
    BYPRODUCTS ${KERNEL_LINKED}
    COMMENT "Linking the kernel"
    VERBATIM
)

# Create a disk image with bootloader and kernel
add_custom_command(
    OUTPUT ${DISK_IMAGE}
    COMMAND dd if=/dev/zero of=${DISK_IMAGE} bs=512 count=2880
    COMMAND dd if=${BOOTLOADER_BINARY} of=${DISK_IMAGE} conv=notrunc
    COMMAND dd if=${KERNEL_LINKED} of=${DISK_IMAGE} bs=512 seek=1 conv=notrunc
    DEPENDS ${BOOTLOADER_BINARY} ${KERNEL_LINKED}
    COMMENT "Creating disk image"
    VERBATIM
)

# Custom target to make sure everything gets built
add_custom_target(epsiworld ALL
    DEPENDS ${DISK_IMAGE}
    COMMENT "Building epsiworld OS"
)

# QEMU run target
add_custom_target(run
    COMMAND qemu-system-i386 -drive format=raw,file=${DISK_IMAGE}
    DEPENDS ${DISK_IMAGE}
    COMMENT "Running epsiworld OS in QEMU"
    VERBATIM
)

# Install the final binary
install(FILES ${DISK_IMAGE} DESTINATION bin)