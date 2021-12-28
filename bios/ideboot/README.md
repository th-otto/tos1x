# ideboot
IDE Autoboot patch for TOS 1.04, 1.06 and 1.62

Copyright (c) 2020-2021, Christian Zietz <czietz@gmx.net>  
Modified for integration into sources by Th.Otto

## Usage
Edit the file `localcnf.mak` in the top level directory,
and add the following lines:
```
BINEXACT:=0
COUNTRY:=de
RAMVERSION:=0
TOSVERSION:=104
```
(adjust the language code to your needs).

Edit the file `common/localcnf.h`, and add the following lines:
```
#define TP_64 1
```
You can also activate other patches here. See the file [common/patchdef.h](/common/patchdef.h)
for available options.

Then compile TOS as usual, and you will get a patched TOS ROM image.

## Notes
The code uses a short timeout for IDE devices, in order not to delay
booting too much when no IDE device is connected. The timeout is more
than sufficient for modern devices such as IDE/SD adapters, CF cards,
IDE DOMs, etc. Booting from a mechanical harddisk, that takes tens of
seconds to spin up, might only be possible after pressing the reset
button.
