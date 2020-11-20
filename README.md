libsndfile binaries
===================

This repository provides pre-compiled dynamic libraries for
[libsndfile](http://www.mega-nerd.com/libsndfile/).
The files have no dependencies on other libraries, support for
[FLAC](https://xiph.org/flac/) and [Ogg Vorbis](http://xiph.org/vorbis/)
is built-in statically.


DLLs for Windows (32-bit and 64-bit)
------------------------------------

The DLLs were created on a Debian GNU/Linux system using
[MXE](http://mxe.cc/) ([this version](https://github.com/mxe/mxe/tree/9e5f267e02e3aaa676d910dde572c848650cc04e), using
[libsndfile-1.0.28.tar.gz](http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.28.tar.gz))
with the following commands (after installing the
[dependencies](http://mxe.cc/#requirements)):

    git clone https://github.com/mxe/mxe.git
    export PATH=$(pwd)"/mxe/usr/bin:$PATH"
    for TARGET in x86_64-w64-mingw32.static i686-w64-mingw32.static
    do
        make -C mxe libsndfile MXE_TARGETS=$TARGET
        $TARGET-gcc -O2 -shared -o libsndfile-$TARGET.dll -Wl,--whole-archive -lsndfile -Wl,--no-whole-archive -lvorbis -lvorbisenc -logg -lFLAC
        $TARGET-strip libsndfile-$TARGET.dll
        chmod -x libsndfile-$TARGET.dll
    done
    mv libsndfile-x86_64-w64-mingw32.static.dll libsndfile64bit.dll
    mv libsndfile-i686-w64-mingw32.static.dll libsndfile32bit.dll


dylib for Mac OS X (64-bit)
---------------------------

The dylib was created on a macOS system using XCode.
The XCode CLI tools were installed with:

    xcode-select --install

Edit the versions of required libraries in the `mac_build.sh` file, then run the script to build `libsndfile.dylib`:

    ./mac_build.sh

Copyright
---------

* Libsndfile by Erik de Castro Lopo, GNU Lesser General Public License (LGPL).

* FLAC by Josh Coalson and Xiph.Org Foundation, 3-clause BSD License.

* Ogg Vorbis by Xiph.Org Foundation, 3-clause BSD License.
