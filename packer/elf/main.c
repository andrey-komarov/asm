#include <stdio.h>
#include <elf.h>
#include <string.h>

#define BUFSIZE (1 << 10)

char buf[BUFSIZE];

char strtab[28] =
        "\x00"          // + 0x00
        ".shstrtab\x00" // + 0x01
        ".text\x00"     // + 0x0b
        ".data\x00"     // + 0x11
        ".bss\x00";     // + 0x17
char text[32] =
        "\xbb\x01\x00\x00\x00" // mov ebx, 1
        "\xb9\xa0\x90\x04\x08" // mov ecx, 0x80490a0
        "\xba\x05\x00\x00\x00" // mov edx, 5
        "\xb8\x04\x00\x00\x00" // mov eax, 4
        "\xcd\x80"                // int 80h
        "\x31\xdb"                // xor ebx, ebx
        "\xb8\x01\x00\x00\x00" // mov eax, 1
        "\xcd\x80"                // int 80h
        "\x00";                    // align
char data[8] =
        "ololo\x00"
        "\x00\x00"; // align

int main(void)
{
    FILE* in = fopen("a.out", "r");
    size_t size = fread(buf, 1, BUFSIZE, in);
    Elf32_Ehdr header;
    memcpy(&header, buf, sizeof(Elf32_Ehdr));
    Elf32_Shdr sections[10];
    memcpy(sections, buf + header.e_shoff, header.e_shnum * sizeof(Elf32_Shdr));
    Elf32_Phdr programs[10];
    memcpy(programs, buf + header.e_phoff, header.e_phnum * sizeof(Elf32_Phdr));
    printf("%d %d %d %d\n", size, sizeof(Elf32_Ehdr), sizeof(Elf32_Shdr), sizeof(Elf32_Phdr));

    Elf32_Ehdr head;
    head.e_ident[0] = ELFMAG0; // MAGIC0 0xfe
    head.e_ident[1] = ELFMAG1; // MAGIC1 'E'
    head.e_ident[2] = ELFMAG2; // MAGIC2 'L'
    head.e_ident[3] = ELFMAG3; // MAGIC3 'F'
    head.e_ident[4] = ELFCLASS32; // File class 0x01
    head.e_ident[5] = ELFDATA2LSB; // 0x01020304 -> 04 03 02 01
                                   // Needed by Intel  = 0x01
    head.e_ident[6] = EV_CURRENT; // Version 0x01
    head.e_ident[7] = 0;
    memset(&head + 8, 0, 8);
    head.e_type = ET_EXEC; // 0x02
    head.e_machine = EM_386; // 0x03
    head.e_version = EV_CURRENT; // 0x01
    head.e_entry = 134512768;
    head.e_phoff = 0x34; // program header table offset
    head.e_shoff = sizeof(Elf32_Ehdr) + 2 * sizeof(Elf32_Phdr) + sizeof(strtab) + sizeof(data) + sizeof(text); // section header table offset
    head.e_flags = 0;
    head.e_ehsize = 0x34; // ELF header size
    head.e_phentsize = 0x20; // ??? program header size
    head.e_phnum = 2; // program header entry table size
    head.e_shentsize = 0x28; // section header size
    head.e_shnum = 5; // section headers
    head.e_shstrndx = 4; // index in sections table

    Elf32_Shdr zero_h;
    memset(&zero_h, 0, sizeof(zero_h));

    Elf32_Shdr text_h;
    text_h.sh_name = 0x0b;
    text_h.sh_type = SHT_PROGBITS;
    text_h.sh_flags = SHF_EXECINSTR | SHF_ALLOC;
    text_h.sh_addr = 134512768;
    text_h.sh_offset = sizeof(Elf32_Ehdr) + head.e_phnum * sizeof(Elf32_Phdr);
    text_h.sh_size = sizeof(text);
    text_h.sh_link = SHN_UNDEF;
    text_h.sh_info = 0;
    text_h.sh_addralign = 16;
    text_h.sh_entsize = 0;

    Elf32_Shdr data_h;
    data_h.sh_name = 0x11;
    data_h.sh_type = SHT_PROGBITS;
    data_h.sh_flags = SHF_WRITE | SHF_ALLOC;
    data_h.sh_addr = 134516896;
    data_h.sh_offset = text_h.sh_offset + text_h.sh_size;
    data_h.sh_size = sizeof(data);
    data_h.sh_link = 0;
    data_h.sh_info = 0;
    data_h.sh_addralign = 4;
    data_h.sh_entsize = 0;

    Elf32_Shdr bss_h;
    bss_h.sh_name = 0x17;
    bss_h.sh_type = SHT_NOBITS;
    bss_h.sh_flags = SHF_ALLOC | SHF_WRITE;
    bss_h.sh_addr = data_h.sh_addr + data_h.sh_size;
    bss_h.sh_offset = data_h.sh_offset + data_h.sh_size;
    bss_h.sh_size = 8;
    bss_h.sh_link = 0;
    bss_h.sh_info = 0;
    bss_h.sh_addralign = 4;
    bss_h.sh_entsize = 0;

    Elf32_Shdr strtab_h;
    strtab_h.sh_name = 0x01;
    strtab_h.sh_type = SHT_STRTAB;
    strtab_h.sh_flags = 0;
    strtab_h.sh_addr = 0;
    strtab_h.sh_offset = bss_h.sh_offset;
    strtab_h.sh_size = sizeof(strtab);
    strtab_h.sh_link = 0;
    strtab_h.sh_info = 0;
    strtab_h.sh_addralign = 1;
    strtab_h.sh_entsize = 0;


    Elf32_Phdr program;
    program.p_type = PT_LOAD;
    program.p_offset = 0;
    program.p_vaddr = 134512640;
    program.p_paddr = 134512640;
    program.p_filesz = bss_h.sh_offset;
    program.p_memsz = bss_h.sh_offset;
    program.p_flags = PF_X | PF_R;
    program.p_align = 4096;

    Elf32_Phdr program2;
    program2.p_type = PT_LOAD;
    program2.p_offset = data_h.sh_offset;
    program2.p_vaddr = 134516896;
    program2.p_paddr = program2.p_vaddr;
    program2.p_filesz = data_h.sh_size;
    program2.p_memsz = bss_h.sh_size + data_h.sh_size;
    program2.p_flags = PF_R | PF_W;
    program2.p_align = 4096;

    FILE* out = fopen("b.out", "w");
    fwrite(&head, sizeof(head), 1, out);
    fwrite(&program, sizeof(program), 1, out);
    fwrite(&program2, sizeof(program2), 1, out);
    fwrite(text, sizeof(text), 1, out);
    fwrite(data, sizeof(data), 1, out);
    fwrite(strtab, sizeof(strtab), 1, out);
    fwrite(&zero_h, sizeof(zero_h), 1, out);
    fwrite(&text_h, sizeof(text_h), 1, out);
    fwrite(&data_h, sizeof(data_h), 1, out);
    fwrite(&bss_h, sizeof(bss_h), 1, out);
    fwrite(&strtab_h, sizeof(strtab_h), 1, out);
    return 0;
}

