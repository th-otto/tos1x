# What is this?

These are the sources used to build orginal ROM versions of TOS 1.04/1.06,
the OS used by Atari ST (not TT).

The goal of this project was to actually be able to
regenerate the original ROM images. Some of the sources used herein were
already done as part of the TOS 2.x project, except for the desktop
which is completely different (but somewhat similar to the PC & DRI versions).
They are not meant to be a base for serious further development, the Alcyon
compiler tools that were originally used are just too outdated and buggy.

It is therefor mainly intended to be used as reference.


# Directory Structure

- bin:  
  Prebuild binaries of tools used in the build process. These are
  essentially identical to the ones from the developer kit, with 
  a few modifications. Sources of almost all of these tools are found
  in the [alcyon archive](http://tho-otto.de/download/alcyon.tar.bz2) of the TOS 2.06/3.06 project.

  It also contains a few tools that are not part of the developer-kit,
  but are now used in the build process (sed, rm, mv and bc). Those
  are taken from GNU packages.

  Note that the code generator and assembler have been hacked to
  automatically support the line-f dispatcher that is used in 1.04
  to save some ROM space. Without these, you won't get a binary exact
  image, nor a working ROM, since it will be too large to fit in 192k.

- bin64:  
  Same tools as above, but compiled for linux-64bit. The cc68 executable
  in this directory is just a shell script that recognizes a few of
  the usual unix cc switches, and translates them to call the various
  alcyon executables.

- include:  
  Include files for the C compiler. Only a few of them are actually
  needed for TOS itself, most of them are only needed to build the
  tools.

- lib:  
  Prebuild libraries and startup files for the C runtime library.
  None of these is linked into a ROM image, they are only used for the tools.

- bios:  
  Source of the BIOS part of TOS.

- vdi:  
  Source of the VDI part of TOS.

- bdos:  
  Source of the GEMDOS part of TOS.

- aes:  
  Source of the AES part of TOS.

- desk:  
  Source of the desktop application.

- common:  
  Shared include files for the above components.

- tools:  
  Source of some small tools used in the build process,
  namely the one that glues the builtin resources and
  newdesk/desktop.inf files together. If you are cross-compiling,
  these must be compiled by your native host compiler.

- listings:  
  Disassembler listings of various TOS versions that were used while
  working on some parts of the system.

- glue:  
  The final ROM images will be build here. It also contains link maps
  for some ROM versions, for reference. The identifiers in those maps
  are truncated to 8 characters, though (a limitation of the DRI
  object file format).


# Assembler sources


- Assembler sources are written in a format that is accepted
  both by as68 and by the GNU assembler with the --mri option.
  If you have to use a different assembler, they might need
  conversion.

- All comments in assembly files are in C-style. The makefile
  preprocesses them before passing them to the assembler. This
  avoids problems with different types of comment delimiters in
  different assemblers, and also works around some bugs of
  the conditional assembly directives of as68. It also allows
  using the same files defining some key constants to be
  used for both assembler and C.

- Don't put comments after constants that are used in assembler
  expressions. Since it is a K&R preprocessor, the spaces between
  the constant and the comment will make it to the source, and
  the assembler does not like spaces in operands.

- Assembling the assembler sources in the bios directory with
  the original as68 from the developer kit will not work, mostly
  because it does not support abs.w addressing mode, but also due
  to numerous bugs. Either use the fixed version from the bin
  directory or try some other assembler.


# Supported versions

BIOS, VDI, GEMDOS, AES, DESKTOP: 1.04 and 1.06


# Supported language versions

 - us - USA
 - de - Germany
 - fr - France
 - uk - United Kingdom (uses US resources)
 - es - Spain
 - it - Italy (no ROM yet found to verify)
 - se - Sweden (the ROM has some patches applied)
 - fi - Finland (uses swedish keyboard and resources)
 - no - Norway (uses swedish keyboard and resources)
 - sf - Switzerland (French) (uses french keyboard and resources)
 - sg - Switzerland (German) (uses german keyboard and resources)
 - nl - Netherlands
 - cz - Czech (originally was a patched german version)

# How to compile

If you are feeling adventurous and want to try to compile
it yourself:

- unpack the archive in some directory of your choice. All pathnames used
  in the makefiles are relative, so its name does not matter. Sources,
  object files and any built files will need ~13MB of disk space.

- install some shell. In my case i used GEMINI (unfortunately german only).
  bash might work, but some of the tools will have problems with MiNT which
  bash requires. Using command.tos from the bin directory should also work.

- cd to the toplevel directory

- make sure the bin directory from the archive is on your PATH:  
  ```PATH=$PWD\bin,$PATH```  
  (for gemini/mupfel; other shells might use ';' as path separator)

- type "make"
  This should build the default configuration (german TOS 1.04).
  If the build succeeds, the final image will be found in the "glue" directory.

- for building other configurations, you can say e.g.  
  ```make COUNTRY=us```  
  Alternatively, you can edit config.mak in the toplevel directory.
  See there also for a list of valid configurations.
  Also, when switching configurations, always make sure to run  
  ```make clean```  
  first.
  If you pass the configuration via commandline, be sure to always
  use the same command when having to restart make.

- Be patient. Using some emulator should take less than a minute to
  compile the sources, but on real hardware it may take several hours.

You can also cross-compile the sources on linux, using the tools in the bin64
directory. In that case, it is assumed that GNU make is used, and will pick
up the GNUmakefile in each directory instead of the Makefile.
With parallel makes that will give you compilation times of less than a second
for the whole source tree.

# Customizing TOS

There are basically two methods to create a customized TOS, ie. one that
contains some patches for known bugs, or small enhancements.

- Use [TOSPATCH](https://github.com/markusheiden/tospatch). This is a command line tool that is able to
  apply lots of patches to an existing TOS, using a configuration file.
  Please read the included documentation on how to use it. The [TOSPATCH](tospatch)
  directory in this repository contains an updated version of the configuration file
  that should work for all languages in most cases.

- Activate some patches while compiling TOS. To do this, you have to
  edit the file `localcnf.mak` in the top level directory,
  and add the following lines:
  ```
  BINEXACT:=0
  COUNTRY:=de
  RAMVERSION:=0
  TOSVERSION:=104
  ```
  (adjust the language code to your needs).

  Edit the file `common/localcnf.h`, and add eg. the following line:
  ```
  #define TP_13 1
  ```
  to activate the fix for the boot-device bug. See the file [common/patchdef.h](/common/patchdef.h)
  for available options.

  Then compile TOS as usual, and you will get a patched TOS ROM image.

# Differences between TOS versions

User visible differences between 1.06 and 1.04 that have been identified:

### BIOS

  * At places where the hardware video base is set/read, also the low byte is read/written.
  * During boot, the microwire interface is initialized. Other than that, there is no support for that hardware.
  * The ramtop/ramvalid system variables are set, but no attempt is made to probe for TT-RAM
  * A small cookiejar is installed (with 8 entries), containing values for _CPU, _MCH, _SND and _SWI. Strangely, no _VDO cookie is set.
  * the system variables kcl_hook and bell_hook are supported, to allow for custom sounds.
  * The bios/xbios entry points are aware of the longframe variable, just like TOS 2.06
  * A simple priviledge violation handler is installed, to catch "move SR,dn" in user mode. This is an allowed instruction on 68000, but gives an exception on 68010+. However unlike later TOS versions, the handler only catches move to data-register, changing that into a "move ccr,dn"
  * The floppy routines use the hz_200 variable for timeouts instead of a fixed counter (again, that is also done in 2.06)
  * The default palette includes the additional bit for all white values. Similarly, Setcolor() does not mask that out.
  * The Rsconf() bug that prevents you from activating RTS/CTS control was fixed.

### GEMDOS
  * just like BIOS, the GEMDOS entry point checks for the _longframe variable. There is however a serious bug in the internal function that starts a new gemdos process, where that check is missing.
  * A small fix in the function that checks for Ctrl-C. Same fix is also present in later GEMDOS versions (although it still reports version 0.15)
  * When a process terminates, GEMDOS internalls updates the system time from BIOS. That is now done with a proper XBIOS call instead of calling the internal BIOS function directly.

### VDI
  * vs_color/vq_color handle the STE colors.

### AES
  * The linef trap is no longer used for internal functions.
  * The internal AES entry has been slightly reorganized. Same version already as in TOS 2.x
  * The rarely encounterd bug to look up an application name from a path has been fixed.

### Desktop
  * When viewing a text file, the mouse button can be used to scroll a page.
  * A new bug has been introduced that prevents you from booting in medium resolution.
