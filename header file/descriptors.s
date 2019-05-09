
.macro mSetupIDT
  mSetupIDT:
	  mov   ax, 0x0000                    # Have es:di point to 0000:0000
	  mov   es, ax
	  mov   di, 0
	  mov   cx, 2048                      # Write 2048 zeroes
	  rep   stosb                         # since the 2048 has 256 entries of 8 bytes.
.endm

# 
# Setup global descriptor table at 0000:0800.
# It has a NULL-descriptor, a code descriptor and a data descriptor.
# A NULL-descriptor is actually necessary for the processor's memory
# protection features.
# 
.macro mSetupGDT
  mSetupGDT:
	  # NULL Descriptor:
	  mov   cx, 4                         # Write the NULL descriptor,
	  rep   stosw                         # which is 4 zero-words.
	  
	  # Code segment descriptor:
	  mov   es:[di], word ptr 0xffff      # limit = 0xffff (since granularity bit is set, this is 4 GB)
	  mov   es:[di+2], word ptr 0x0000    # base  = 0x0000
	  mov   es:[di+4], byte ptr 0x0       # base
	  mov   es:[di+5], byte ptr 0x9a      # access = 1001 1010; segment present, ring 0, S=code/data, type=0xA (code, execute/read)
	  mov   es:[di+6], byte ptr 0xcf      # granularity = 1100 1111; limit = 0xff, AVL=0, L=0, 32bit, G=1
	  mov   es:[di+7], byte ptr 0x00      # base
	  add   di, 8
	  
	  # Data segment descriptor:
	  mov   es:[di], word ptr 0xffff      # limit = 0xffff (since granularity bit is set, this is 4 GB)
	  mov   es:[di+2], word ptr 0x0000    # base  = 0x0000
	  mov   es:[di+4], byte ptr 0x0       # base
	  mov   es:[di+5], byte ptr 0x92      # access = 1001 0010; segment present, ring 0, S=code/data, type=0x2 (code, read/write)
	  mov   es:[di+6], byte ptr 0xcf      # granularity = 1100 1100; limit = 0xff, AVL=0, L=0, 32bit, G=1
	  mov   es:[di+7], byte ptr 0x00      # base
.endm  

.macro mLoadDescriptorTables
	  lgdt  gdt
	  lidt  idt
.endm
