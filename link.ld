/* Tell the linker that we want an x86_64 ELF64 output file */
OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)
 
/* We want the symbol _start to be our entry point */
ENTRY(_start)
 
/* Define the program headers we want so the bootloader gives us the right */
/* MMU permissions */
PHDRS
{
    text    PT_LOAD    FLAGS((1 << 0) | (1 << 2)) ; /* Execute + Read */
    rodata  PT_LOAD    FLAGS((1 << 2)) ;            /* Read only */
    data    PT_LOAD    FLAGS((1 << 1) | (1 << 2)) ; /* Write + Read */
    dynamic PT_DYNAMIC FLAGS((1 << 1) | (1 << 2)) ; /* Dynamic PHDR for relocations */
}
 
SECTIONS
{
    /* We wanna be placed in the topmost 2GiB of the address space, for optimisations */
    /* and because that is what the Limine spec mandates. */
    /* Any address in this region will do, but often 0xffffffff80000000 is chosen as */
    /* that is the beginning of the region. */
    . = 0xffffffff80000000;
 
    /*All Sections are aligned on a 64k boundary*/
    .text ALIGN(0x10000) : {
        kernel_text_begin = .
        *(.text .text.*)
    } :text
    kernel_text_end = .
 

    .rodata ALIGN(0x10000) : {
        kernel_rdata_begin = .
        *(.rodata .rodata.*)
    } :rodata
    kernel_rdata_end = .
 

    .data ALIGN(0x10000) : {
        kernel_data_begin = .
        *(.data .data.*)
    } :data
    kernel_data_end = .

    /* Dynamic section for relocations, both in its own PHDR and inside data PHDR */
    .dynamic ALIGN(0x10000) : {
        kernel_dyn_begin = .
        *(.dynamic)
    } :data :dynamic
    kernel_dyn_end = .

    .tls ALIGN(0x10000) : {
        kernel_tls_begin = .
        *(.tdata .tdata.*)
        *(.tbss .tbss.*)
    } :data
    kernel_tls_end = .

    /* NOTE: .bss needs to be the last thing mapped to :data, otherwise lots of */
    /* unnecessary zeros will be written to the binary. */
    /* If you need, for example, .init_array and .fini_array, those should be placed */
    /* above this. */
    .bss ALIGN(0x10000) : {
        kernel_bss_begin = .
        *(.bss .bss.*)
        *(COMMON)
    } :data
    kernel_bss_end = .

    /* Discard .note.* and .eh_frame since they may cause issues on some hosts. */
    /DISCARD/ : {
        *(.eh_frame)
        *(.note .note.*)
    }
}