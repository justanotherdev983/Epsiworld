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


# Define output files
set(BOOTLOADER_BINARY ${CMAKE_BINARY_DIR}/bootloader.bin)
set(KERNEL_ENTRY_RAW ${CMAKE_BINARY_DIR}/kernel_entry.bin)
set(KERNEL_ENTRY_BINARY ${CMAKE_BINARY_DIR}/kernel_entry.o)
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

# First, assemble the kernel entry using FASM to produce a raw binary
add_custom_command(
    OUTPUT ${KERNEL_ENTRY_RAW}
    COMMAND fasm ${KERNEL_ENTRY_SOURCE} ${KERNEL_ENTRY_RAW}
    DEPENDS ${KERNEL_ENTRY_SOURCE}
    COMMENT "Assembling the kernel entry with FASM"
    VERBATIM
)

# Then convert the raw binary to an ELF object file
add_custom_command(
    OUTPUT ${KERNEL_ENTRY_BINARY}
    COMMAND objcopy -I binary -O elf32-i386 -B i386 --rename-section .data=.text,code,readonly ${KERNEL_ENTRY_RAW} ${KERNEL_ENTRY_BINARY} --redefine-sym _binary_${CMAKE_BINARY_DIR}_kernel_entry_bin_start=kernel_entry
    DEPENDS ${KERNEL_ENTRY_RAW}
    COMMENT "Converting FASM binary to ELF object file"
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
add_library(kernel_obj OBJECT ${KERNEL_CPP_SOURCE} ${MEMORY_CPP_SOURCE} ${KEYBOARD_CPP_SOURCE}  ${TERMINAL_CPP_SOURCE}) 
target_include_directories(kernel_obj PRIVATE ${INCLUDE_DIR})

# Link the kernel using explicit paths to object files
add_custom_command(
    OUTPUT ${KERNEL_LINKED}
    COMMAND ld -m elf_i386 -T ${CMAKE_BINARY_DIR}/linker.ld -o ${KERNEL_LINKED}
            ${KERNEL_ENTRY_BINARY} 
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/kernel/kernel.cpp.o
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/libc/memory.cpp.o
            ${CMAKE_BINARY_DIR}/CMakeFiles/kernel_obj.dir/src/drivers/terminal.cpp.o
    DEPENDS ${KERNEL_ENTRY_BINARY} kernel_obj ${CMAKE_BINARY_DIR}/linker.ld
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
