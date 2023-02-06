OGGVERSION=1.3.5
VORBISVERSION=1.3.7
FLACVERSION=1.4.2
OPUSVERSION=1.3.1
MPG123VERSION=1.30.2
LAMEVERSION=3.100
SNDFILE_VERSION=1.2.0

JOBS=8
SNDFILENAME=libsndfile-$SNDFILE_VERSION
OGG_INCDIR="$(pwd)/libogg-$OGGVERSION/include"
OGG_LIBDIR="$(pwd)/libogg-$OGGVERSION/src/.libs"

if [ "$1" = "arm64" ]; then
    echo "Cross compiling for Darwin arm64.."
    export MACOSX_DEPLOYMENT_TARGET=11.0
    BUILD_HOST="--host=aarch64-apple-darwin --target=arm64-apple-macos11"
    EXTRA_CFLAGS="-arch arm64 -target arm64-apple-macos11"
else
    echo "Building for Darwin $(uname -m).."
    export MACOSX_DEPLOYMENT_TARGET=10.9
    BUILD_HOST=""
    EXTRA_CFLAGS=""
fi

# libogg

curl -LO https://downloads.xiph.org/releases/ogg/libogg-$OGGVERSION.tar.gz
tar zxvf libogg-$OGGVERSION.tar.gz
cd libogg-$OGGVERSION
CFLAGS=$EXTRA_CFLAGS CXXFLAGS=$EXTRA_CFLAGS ./configure $BUILD_HOST --disable-shared --enable-shared
make -j$JOBS
cd ..

# libvorbis

curl -LO https://downloads.xiph.org/releases/vorbis/libvorbis-$VORBISVERSION.tar.gz
tar zxvf libvorbis-$VORBISVERSION.tar.gz
cd libvorbis-$VORBISVERSION
CFLAGS=$EXTRA_CFLAGS CXXFLAGS=$EXTRA_CFLAGS ./configure $BUILD_HOST --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libFLAC

curl -LO https://downloads.xiph.org/releases/flac/flac-$FLACVERSION.tar.xz
unxz flac-$FLACVERSION.tar.xz
tar zxvf flac-$FLACVERSION.tar
cd flac-$FLACVERSION
CFLAGS=$EXTRA_CFLAGS CXXFLAGS=$EXTRA_CFLAGS ./configure $BUILD_HOST --enable-static --disable-shared --with-ogg-includes=$OGG_INCDIR --with-ogg-libraries=$OGG_LIBDIR
make -j$JOBS
cd ..

# libopus

curl -LO https://archive.mozilla.org/pub/opus/opus-$OPUSVERSION.tar.gz
tar zxvf opus-$OPUSVERSION.tar.gz
cd opus-$OPUSVERSION
ln -sf include opus
CFLAGS=$EXTRA_CFLAGS CXXFLAGS=$EXTRA_CFLAGS ./configure $BUILD_HOST --disable-shared --enable-static
make -j$JOBS
cd ..

# mpg123

curl -LO https://sourceforge.net/projects/mpg123/files/mpg123/$MPG123VERSION/mpg123-$MPG123VERSION.tar.bz2
tar zxvf mpg123-$MPG123VERSION.tar.bz2
cd mpg123-$MPG123VERSION
CFLAGS=$EXTRA_CFLAGS CXXFLAGS=$EXTRA_CFLAGS ./configure $BUILD_HOST --enable-static --disable-shared
make -j$JOBS
cd ..

# liblame

curl -LO https://sourceforge.net/projects/lame/files/lame/$LAMEVERSION/lame-$LAMEVERSION.tar.gz
tar zxvf lame-$LAMEVERSION.tar.gz
cd lame-$LAMEVERSION
ln -sf include lame
CFLAGS=$EXTRA_CFLAGS CXXFLAGS=$EXTRA_CFLAGS ./configure $BUILD_HOST --enable-static --disable-shared
make -j$JOBS
cd ..

# libsndfile

export FLAC_INCLUDE="$(pwd)/flac-$FLACVERSION/include"
export FLAC_LIBS="$(pwd)/flac-$FLACVERSION/src/libFLAC/.libs/libFLAC.a"
export OGG_INCLUDE="$(pwd)/libogg-$OGGVERSION/include"
export OGG_LIBS="$(pwd)/libogg-$OGGVERSION/src/.libs/libogg.a"
export VORBIS_INCLUDE="$(pwd)/libvorbis-$VORBISVERSION/include"
export VORBIS_LIBS="$(pwd)/libvorbis-$VORBISVERSION/lib/.libs/libvorbis.a"
export VORBISENC_INCLUDE="$(pwd)/libvorbis-$VORBISVERSION/include"
export VORBISENC_LIBS="$(pwd)/libvorbis-$VORBISVERSION/lib/.libs/libvorbisenc.a"
export OPUS_INCLUDE="$(pwd)/opus-$OPUSVERSION"
export OPUS_LIBS="$(pwd)/opus-$OPUSVERSION/.libs/libopus.a"
export MP3LAME_INCLUDE="$(pwd)/lame-$LAMEVERSION"
export MP3LAME_LIBS="$(pwd)/lame-$LAMEVERSION/libmp3lame/.libs/libmp3lame.a"
export MPG123_INCLUDE="$(pwd)/mpg123-$MPG123VERSION/src/libmpg123"
export MPG123_LIBS="$(pwd)/mpg123-$MPG123VERSION/src/libmpg123/.libs/libmpg123.a"

curl -LO https://github.com/libsndfile/libsndfile/releases/download/$SNDFILE_VERSION/libsndfile-$SNDFILE_VERSION.tar.xz
tar jxvf libsndfile-$SNDFILE_VERSION.tar.xz
cd $SNDFILENAME
if [ "$1" = "arm64" ]; then
cmake -DCMAKE_OSX_ARCHITECTURES=arm64 -DBUILD_SHARED_LIBS=ON -DENABLE_EXTERNAL_LIBS=ON -DENABLE_MPEG=ON -DBUILD_PROGRAMS=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_PROJECT_INCLUDE=../darwin.cmake .
else
cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 -DBUILD_SHARED_LIBS=ON -DENABLE_EXTERNAL_LIBS=ON -DENABLE_MPEG=ON -DBUILD_PROGRAMS=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_PROJECT_INCLUDE=../darwin.cmake .
fi
cmake --build . --parallel $JOBS
cd ..

if [ "$1" = "arm64" ]; then
cp -H $SNDFILENAME/libsndfile.dylib libsndfile_arm64.dylib
chmod -x libsndfile_arm64.dylib
else
cp -H $SNDFILENAME/libsndfile.dylib libsndfile.dylib
chmod -x libsndfile.dylib
fi
