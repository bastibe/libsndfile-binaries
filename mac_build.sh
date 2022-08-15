OGGVERSION=1.3.5
VORBISVERSION=1.3.7
FLACVERSION=1.3.3
OPUSVERSION=1.3.1
MPG123VERSION=1.30.2
LAMEVERSION=3.100
SNDFILE_VERSION=1.1.0

JOBS=8
SNDFILENAME=libsndfile-$SNDFILE_VERSION
OGG_INCDIR="$(pwd)/libogg-$OGGVERSION/include"
OGG_LIBDIR="$(pwd)/libogg-$OGGVERSION/src/.libs"

export MACOSX_DEPLOYMENT_TARGET=10.9

# libogg

curl -LO https://downloads.xiph.org/releases/ogg/libogg-$OGGVERSION.tar.gz
tar zxvf libogg-$OGGVERSION.tar.gz
cd libogg-$OGGVERSION
./configure --disable-shared
make -j$JOBS
cd ..

# libvorbis

curl -LO https://downloads.xiph.org/releases/vorbis/libvorbis-$VORBISVERSION.tar.gz
tar zxvf libvorbis-$VORBISVERSION.tar.gz
cd libvorbis-$VORBISVERSION
./configure --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libFLAC

curl -LO https://downloads.xiph.org/releases/flac/flac-$FLACVERSION.tar.xz
unxz flac-$FLACVERSION.tar.xz
tar zxvf flac-$FLACVERSION.tar
cd flac-$FLACVERSION
./configure --enable-static --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libopus

curl -LO https://archive.mozilla.org/pub/opus/opus-$OPUSVERSION.tar.gz
tar zxvf opus-$OPUSVERSION.tar.gz
cd opus-$OPUSVERSION
./configure --disable-shared
make -j$JOBS
cd ..

# mpg123

curl -LO https://sourceforge.net/projects/mpg123/files/mpg123/$MPG123VERSION/mpg123-$MPG123VERSION.tar.bz2
tar zxvf mpg123-$MPG123VERSION.tar.bz2
cd mpg123-$MPG123VERSION
./configure --enable-static --disable-shared
make -j$JOBS
cd ..

# liblame

curl -LO https://sourceforge.net/projects/lame/files/lame/$LAMEVERSION/lame-$LAMEVERSION.tar.gz
tar zxvf lame-$LAMEVERSION.tar.gz
cd lame-$LAMEVERSION
./configure --enable-static --disable-shared
make -j$JOBS
cd ..

# libsndfile

export FLAC_CFLAGS="-I$(pwd)/flac-$FLACVERSION/include"
export FLAC_LIBS="$(pwd)/flac-$FLACVERSION/src/libFLAC/libFLAC.la"
export OGG_CFLAGS="-I$(pwd)/libogg-$OGGVERSION/include"
export OGG_LIBS="$(pwd)/libogg-$OGGVERSION/src/libogg.la"
export VORBIS_CFLAGS="-I$(pwd)/libvorbis-$VORBISVERSION/include"
export VORBIS_LIBS="$(pwd)/libvorbis-$VORBISVERSION/lib/libvorbis.la"
export VORBISENC_CFLAGS="-I$(pwd)/libvorbis-$VORBISVERSION/include"
export VORBISENC_LIBS="$(pwd)/libvorbis-$VORBISVERSION/lib/libvorbisenc.la"
export OPUS_CFLAGS="-I$(pwd)/opus-$OPUSVERSION/include"
export OPUS_LIBS="$(pwd)/opus-$OPUSVERSION/libopus.la"
export LAME_CFLAGS="-I$(pwd)/lame-$LAMEVERSION/include"
export LAME_LIBS="$(pwd)/lame-$LAMEVERSION/libmp3lame/.libs/libmp3lame.la"
export MPG123_CFLAGS="-I$(pwd)/mpg123-$MPG123VERSION/src/libmpg123 $LAME_CFLAGS"
export MPG123_LIBS="$(pwd)/mpg123-$MPG123VERSION/src/libmpg123/libmpg123.la $LAME_LIBS"

curl -LO https://github.com/libsndfile/libsndfile/releases/download/$SNDFILE_VERSION/libsndfile-$SNDFILE_VERSION.tar.xz
tar jxvf libsndfile-$SNDFILE_VERSION.tar.xz
cd $SNDFILENAME
./configure --disable-static --disable-sqlite --disable-alsa
make -j$JOBS
cd ..

cp $SNDFILENAME/src/.libs/libsndfile.1.dylib libsndfile.dylib
chmod -x libsndfile.dylib
