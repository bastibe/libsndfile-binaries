JOBS=8
OGGNAME=libogg-1.3.4
VORBISNAME=libvorbis-1.3.7
FLACNAME=flac-1.3.3
OPUSNAME=opus-1.3.1
SNDFILE_VERSION=1.0.30
SNDFILENAME=libsndfile-$SNDFILE_VERSION
OGG_INCDIR="$(pwd)/$OGGNAME/include"
OGG_LIBDIR="$(pwd)/$OGGNAME/src/.libs"

export MACOSX_DEPLOYMENT_TARGET=10.9

# libogg

curl -LO https://downloads.xiph.org/releases/ogg/$OGGNAME.tar.gz
tar zxvf $OGGNAME.tar.gz
cd $OGGNAME
./configure --disable-shared
make -j$JOBS
cd ..

# libvorbis

curl -LO https://downloads.xiph.org/releases/vorbis/$VORBISNAME.tar.gz
tar zxvf $VORBISNAME.tar.gz
cd $VORBISNAME
./configure --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libFLAC

curl -LO https://downloads.xiph.org/releases/flac/$FLACNAME.tar.xz
unxz $FLACNAME.tar.xz
tar zxvf $FLACNAME.tar
cd $FLACNAME
./configure --enable-static --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libopus

curl -LO https://archive.mozilla.org/pub/opus/$OPUSNAME.tar.gz
tar zxvf $OPUSNAME.tar.gz
cd $OPUSNAME
./configure --disable-shared
make -j$JOBS
cd ..

# libsndfile

export FLAC_CFLAGS="-I$(pwd)/$FLACNAME/include"
export FLAC_LIBS="$(pwd)/$FLACNAME/src/libFLAC/libFLAC.la"
export OGG_CFLAGS="-I$(pwd)/$OGGNAME/include"
export OGG_LIBS="$(pwd)/$OGGNAME/src/libogg.la"
export VORBIS_CFLAGS="-I$(pwd)/$VORBISNAME/include"
export VORBIS_LIBS="$(pwd)/$VORBISNAME/lib/libvorbis.la"
export VORBISENC_CFLAGS="-I$(pwd)/$VORBISNAME/include"
export VORBISENC_LIBS="$(pwd)/$VORBISNAME/lib/libvorbisenc.la"
export OPUS_CFLAGS="-I$(pwd)/$OPUSNAME/include"
export OPUS_LIBS="$(pwd)/$OPUSNAME/libopus.la"

curl -LO https://github.com/libsndfile/libsndfile/releases/download/v$SNDFILE_VERSION/$SNDFILENAME.tar.bz2
tar jxvf $SNDFILENAME.tar.bz2
cd $SNDFILENAME
./configure --disable-static --disable-sqlite --disable-alsa --enable-werror
make -j$JOBS
cd ..

cp $SNDFILENAME/src/.libs/libsndfile.1.dylib libsndfile.dylib
chmod -x libsndfile.dylib
