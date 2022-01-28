libsndfile binaries
===================

This repository provides pre-compiled dynamic libraries for
[libsndfile](http://www.mega-nerd.com/libsndfile/).
The files have no dependencies on other libraries, support for
[FLAC](https://xiph.org/flac/) and [Ogg Vorbis](http://xiph.org/vorbis/)
is built-in statically.


DLLs for Windows (32-bit and 64-bit)
------------------------------------

The DLLs are copied from the [libsndfile releases page](https://github.com/libsndfile/libsndfile/releases).

dylib for Mac OS X (64-bit)
---------------------------

The dylib was created on a macOS system using XCode.
The XCode CLI tools were installed with:

    xcode-select --install

Edit the versions of required libraries in the `mac_build.sh` file

    OGGNAME=libogg-1.3.5
    VORBISNAME=libvorbis-1.3.7
    FLACNAME=flac-1.3.3
    OPUSNAME=opus-1.3.1
    SNDFILE_VERSION=1.0.31


Run the script to build `libsndfile.dylib`

    ./mac_build.sh

Copyright
---------

* Libsndfile by Erik de Castro Lopo, GNU Lesser General Public License (LGPL).

* FLAC by Josh Coalson and Xiph.Org Foundation, 3-clause BSD License.

* Ogg Vorbis by Xiph.Org Foundation, 3-clause BSD License.
