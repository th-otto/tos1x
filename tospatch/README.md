# TOSPATCH

This directory contains the [TOSPATCH](https://github.com/markusheiden/tospatch) tool, along with
several useful patches. See the included documentation
on how to use it.

This program was not written by me, but most of the
patch files have been updated so they can be used with
other language versions than german. There are also
now new folders for versions 1.06 and 1.62.

# Known BUGS

 * For 1.06 & 1.62, the WINX patch will only work with the german version.
   For 1.04, it should work with all supported languages.

 * Some patches that replace single items in the resource files (like icons)
   will only work with the german version for now. Replacing the whole
   resource file should work though.

 * Creating relocated images for TOS versions 1.06 and 1.62 currently
   does not work. Do not use that feature.

# Future

Some of the patches that can be applied can also be activated when
compiling the source. Others may follow.  See the file
[patchdef.h](/common/patchdef.h) for available options.

