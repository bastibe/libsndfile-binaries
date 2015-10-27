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
[MXE](http://mxe.cc/) with the following commands (after installing the
[dependencies](http://mxe.cc/#requirements)):

    JOBS=8
    git clone https://github.com/mxe/mxe.git
    export PATH=$(pwd)"/mxe/usr/bin:$PATH"
    for TARGET in x86_64-w64-mingw32.static i686-w64-mingw32.static
    do
        make -C mxe libsndfile -j$JOBS JOBS=$JOBS MXE_TARGETS=$TARGET
        $TARGET-gcc -O2 -shared -o libsndfile-$TARGET.dll -Wl,--whole-archive -lsndfile -Wl,--no-whole-archive -lvorbis -lvorbisenc -logg -lFLAC
        $TARGET-strip libsndfile-$TARGET.dll
        chmod -x libsndfile-$TARGET.dll
    done
    mv libsndfile-x86_64-w64-mingw32.static.dll libsndfile64bit.dll
    mv libsndfile-i686-w64-mingw32.static.dll libsndfile32bit.dll


dylib for Mac OS X (64-bit)
---------------------------

The dylib was created on a Mac OS X system using the following commands
(after installing the necessary programs like make, GCC, ...):

    # Make sure that you don't have libogg.dylib already installed!
    # If you have such a file, you should temporarily rename it.

    JOBS=8
    OGGNAME=libogg-1.3.2
    VORBISNAME=libvorbis-1.3.5
    FLACNAME=flac-1.3.1
    SNDFILENAME=libsndfile-1.0.25
    OGG_INCDIR="$(pwd)/$OGGNAME/include"
    OGG_LIBDIR="$(pwd)/$OGGNAME/src/.libs"

    # libogg

    curl -O http://downloads.xiph.org/releases/ogg/$OGGNAME.tar.gz
    tar xvf $OGGNAME.tar.gz
    cd $OGGNAME
    ./configure --disable-shared
    make -j$JOBS
    cd ..

    # libvorbis

    curl -O http://downloads.xiph.org/releases/vorbis/$VORBISNAME.tar.gz
    tar xvf $VORBISNAME.tar.gz
    cd $VORBISNAME
    ./configure --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
    make -j$JOBS
    cd ..

    # libFLAC

    curl -O http://downloads.xiph.org/releases/flac/$FLACNAME.tar.xz
    unxz $FLACNAME.tar.xz
    tar xvf $FLACNAME.tar
    cd $FLACNAME
    ./configure --enable-static --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
    make -j$JOBS
    cd ..

    # libsndfile

    export FLAC_CFLAGS="-I$(pwd)/$FLACNAME/include"
    # to compensate for a typo in configure.ac:
    export FLAC_CLFAGS=$FLAC_CFLAGS
    export OGG_CFLAGS="-I$OGG_INCDIR"
    export VORBISENC_CFLAGS="-I$(pwd)/$VORBISNAME/include"
    # disable pkg-config:
    export PKG_CONFIG=true
    export LIBS="$(pwd)/$FLACNAME/src/libFLAC/libFLAC.la -logg -L$OGG_LIBDIR $(pwd)/$VORBISNAME/lib/libvorbis.la $(pwd)/$VORBISNAME/lib/libvorbisenc.la"

    curl -O http://www.mega-nerd.com/libsndfile/files/$SNDFILENAME.tar.gz
    tar xvzf $SNDFILENAME.tar.gz
    cd $SNDFILENAME
    ./configure --disable-static --disable-sqlite --disable-alsa
    make -j$JOBS
    cd ..

    cp -i $SNDFILENAME/src/.libs/libsndfile.1.dylib libsndfile.dylib


Copyright
---------

* Libsndfile by Erik de Castro Lopo, GNU Lesser General Public License (LGPL).

* FLAC by Josh Coalson and Xiph.Org Foundation, 3-clause BSD License.

* Ogg Vorbis by Xiph.Org Foundation, 3-clause BSD License.
