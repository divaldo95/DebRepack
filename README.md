# Deb Repack
## Information
Compiling a new kernel on Ubuntu (make deb-pkg) created a deb package which can not be installed on Debian, because it does not support zstd compression:

```
dpkg-deb: error: archive 'mypackage.deb' uses unknown compression for member 'control.tar.zst', giving up
```
This can be resolved by repacking the deb content to tar.xz. 
This script does the job, just pass the deb package name to the script and use the *_repacked.deb fron the out folder:
```
./deb_repack.sh mypackage.deb
```

Sample output:
```
Checking file extension...
Creating output directory...
Creating temp directory...
Extracting deb package...
x - tmp/debian-binary
x - tmp/control.tar.zst
x - tmp/data.tar.zst
Extracting control.tar.zst...
tmp/control.tar.zst : 71680 bytes
Extracting data.tar.zst...
tmp/data.tar.zst    : 6748160 bytes
Compressing control.tar.xz...
Compressing data.tar.xz...
Creating new deb package...
Cleaning up...
Done. mypackage.deb repacked as /mydir/out/mypackage_repacked.deb
```

## Requirements
xz-utils, zstd and binutils package must be installed. This can be done on Debian based distros with the following command:
```
# apt install xz-utils zstd binutils
```