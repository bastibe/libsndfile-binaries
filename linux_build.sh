#!/bin/sh

OGGVERSION=1.3.5
VORBISVERSION=1.3.7
FLACVERSION=1.4.3
OPUSVERSION=1.4
MPG123VERSION=1.32.3
LAMEVERSION=3.100
SNDFILE_VERSION=1.2.2

JOBS=8
SNDFILENAME=libsndfile-$SNDFILE_VERSION
OGG_INCDIR="$(pwd)/libogg-$OGGVERSION/include"
OGG_LIBDIR="$(pwd)/libogg-$OGGVERSION/src/.libs"

set -e

# make sure all static libraries are position-independent, so we can link them
# into the libsndfile.so later:
export CFLAGS="-fPIC"
export LDFLAGS="-fPIC"

# libogg

curl -LO https://downloads.xiph.org/releases/ogg/libogg-$OGGVERSION.tar.gz
tar xvf libogg-$OGGVERSION.tar.gz
cd libogg-$OGGVERSION
./configure --disable-shared
make -j$JOBS
cd ..

# libvorbis

export OGG_CFLAGS="-I$OGG_INCDIR"
export OGG_LIBS="-L$OGG_LIBDIR -logg"

curl -LO https://downloads.xiph.org/releases/vorbis/libvorbis-$VORBISVERSION.tar.gz
tar xvf libvorbis-$VORBISVERSION.tar.gz
cd libvorbis-$VORBISVERSION
./configure --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libFLAC

curl -LO https://downloads.xiph.org/releases/flac/flac-$FLACVERSION.tar.xz
tar xvf flac-$FLACVERSION.tar.xz
cd flac-$FLACVERSION
./configure --enable-static --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libopus

curl -LO https://downloads.xiph.org/releases/opus/opus-$OPUSVERSION.tar.gz
tar xvf opus-$OPUSVERSION.tar.gz
cd opus-$OPUSVERSION
./configure --disable-shared
make -j$JOBS
cd ..

# mpg123

curl -LO https://sourceforge.net/projects/mpg123/files/mpg123/$MPG123VERSION/mpg123-$MPG123VERSION.tar.bz2
tar xvf mpg123-$MPG123VERSION.tar.bz2
cd mpg123-$MPG123VERSION
./configure --enable-static --disable-shared
make -j$JOBS
cd ..

# liblame

curl -LO https://sourceforge.net/projects/lame/files/lame/$LAMEVERSION/lame-$LAMEVERSION.tar.gz
tar xvf lame-$LAMEVERSION.tar.gz
cd lame-$LAMEVERSION
./configure --enable-static --disable-shared
make -j$JOBS
cd ..

# libsndfile

export FLAC_CFLAGS="-I$(pwd)/flac-$FLACVERSION/include/"
export FLAC_LIBS="-L$(pwd)/flac-$FLACVERSION/src/libFLAC/.libs/ -lFLAC"
export OGG_CFLAGS="-I$(pwd)/libogg-$OGGVERSION/include/"
export OGG_LIBS="-L$(pwd)/libogg-$OGGVERSION/src/.libs/ -logg"
export VORBIS_CFLAGS="-I$(pwd)/libvorbis-$VORBISVERSION/include/"
export VORBIS_LIBS="-L$(pwd)/libvorbis-$VORBISVERSION/lib/.libs/ -lvorbis"
export VORBISENC_CFLAGS="-I$(pwd)/libvorbis-$VORBISVERSION/include/"
export VORBISENC_LIBS="-L$(pwd)/libvorbis-$VORBISVERSION/lib/.libs/ -lvorbisenc"
export OPUS_CFLAGS="-I$(pwd)/opus-$OPUSVERSION/include/"
export OPUS_LIBS="-L$(pwd)/opus-$OPUSVERSION/.libs/ -lopus"
export LAME_CFLAGS="-I$(pwd)/lame-$LAMEVERSION/include/"
export LAME_LIBS="-L$(pwd)/lame-$LAMEVERSION/libmp3lame/.libs/"
export MPG123_CFLAGS="-I$(pwd)/mpg123-$MPG123VERSION/src/libmpg123/ $LAME_CFLAGS"
export MPG123_LIBS="-L$(pwd)/mpg123-$MPG123VERSION/src/libmpg123/.libs/ -lmpg123 -lmp3lame $LAME_LIBS"

# add some global flags that libsndfile's compile script doesn't pick up
# correctly from the above variables:
export CFLAGS="$LAME_CFLAGS"
export LDFLAGS="$MPG123_LIBS"

# copy opus and lame headers into a subdirectory, as they are imported as opus/opus.h and lame/lame.h:
mkdir -p opus-$OPUSVERSION/include/opus
cp opus-$OPUSVERSION/include/*.h opus-$OPUSVERSION/include/opus
mkdir -p lame-$LAMEVERSION/include/lame
cp lame-$LAMEVERSION/include/*.h lame-$LAMEVERSION/include/lame

curl -LO https://github.com/libsndfile/libsndfile/releases/download/$SNDFILE_VERSION/libsndfile-$SNDFILE_VERSION.tar.xz
tar xvf libsndfile-$SNDFILE_VERSION.tar.xz
cd $SNDFILENAME
./configure --disable-static --disable-sqlite --disable-alsa --enable-external-libs --enable-mpeg
make -j$JOBS
cd ..

cp $SNDFILENAME/src/.libs/libsndfile.so libsndfile.so
chmod -x libsndfile.so
