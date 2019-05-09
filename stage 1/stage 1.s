
.code16
.intel_syntax noprefix
.text
.org 0x0                                        

LOAD_SEGMENT = 0x1000                     # stage 2 loader will be loader into segment 1000h
FAT_SEGMENT  = 0x0ee0                     # The boot disk's FAT will be loaded into segment 0x0ee0 
                                          # (9*512 bytes under stage 2 loader, because the FAT
                                          # consists of 9 512-byte segments).

.global main

main:
    jmp short start                       # jump to beginning of code
    nop                                   # Boot sector data starts 3 bytes from beginning, hence nop

.include "bootsector.s"
.include "macros.s"

start:
  mInitSegments                           # Initialize memory segments used by this program
  mResetDiskSystem                        # Reset the disk system
  mWriteString loadmsg                    # Display "loading..."
  mFindFile filename, LOAD_SEGMENT        # Find the stage 2 file in the root directory
  mReadFAT FAT_SEGMENT                    # Load the FAT table into memory
  mReadFile LOAD_SEGMENT, FAT_SEGMENT     # Read the stage 2 file into memory
  mStartSecondStage                       # Execute the stage 2 file.

# 
# Booting has failed because of a disk error. 
# Inform the user and reboot.
# 
bootFailure:
  mWriteString diskerror                  # Show "Disk error, press key to reboot"
  mReboot                                 # Reboot
  

.include "functions.s"
    
# PROGRAM DATA
filename:    .asciz "STAGE2BIN"
rebootmsg:   .asciz "Press any key to reboot.\r\n"
diskerror:   .asciz "Disk error. "
loadmsg:     .asciz "Loading  BBOS...\r\n"

root_strt:   .byte 0,0      # hold offset of root directory on disk
root_scts:   .byte 0,0      # holds # sectors in root directory
file_strt:   .byte 0,0      # holds offset of bootloader on disk

.fill (510-(.-main)), 1, 0  # Pad with nulls up to 510 bytes (excl. boot magic)
BootMagic:  .int 0xAA55     # magic word for BIOSBootMagic:  .int 0xAA55     # magic word for BIOS
