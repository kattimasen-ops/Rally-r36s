#!/bin/sh

#
# Build script for Trigger Rally, for Windows 32-bit, using MSYS2.
#
# Last updated:     2019-02-25
# TR version:       0.6.6.1
#

#
# set variables according to the current release and library versions
#
CFG_OPTIMS="-march=i686 -mtune=generic -O2"
CFG_HOST="mingw32"
CFG_PREFIX="/usr/local"
DN_JPEG="jpeg-9c"
DN_ZLIB="zlib-1.2.11"
DN_LIBPNG="libpng-1.6.36"
DN_GLEW="glew-2.1.0"
DN_SDL="SDL2-2.0.9"
DN_SDLIMG="SDL2_image-2.0.4"
DN_PHYSFS="physfs-3.0.1"
DN_TINYXML="tinyxml2-7.0.1"
DN_TRIGGER="trigger-rally-0.6.6.1"

#
# clean old binaries
#
rm --recursive --dir --verbose $CFG_PREFIX/*

#
# build and install libjpeg
#
cd $DN_JPEG
sh ./configure \
    --host="$CFG_HOST" --build="$CFG_HOST" --prefix="$CFG_PREFIX" \
    CFLAGS="$CFG_OPTIMS -m32" \
    LDFLAGS="-m32"
make clean
make
make install-strip
cd ..

#
# build and install zlib
#
cd $DN_ZLIB
make \
    SHARED_MODE=1 \
    -f win32/Makefile.gcc clean
make \
    SHARED_MODE=1 \
    CFLAGS="$CFG_OPTIMS -m32" \
    LDFLAGS="-m32" \
    -f win32/Makefile.gcc
make \
    SHARED_MODE=1 \
    INCLUDE_PATH="$CFG_PREFIX/include" \
    LIBRARY_PATH="$CFG_PREFIX/lib" \
    BINARY_PATH="$CFG_PREFIX/bin" \
    -f win32/Makefile.gcc install
cd ..

#
# build and install libpng
#
cd $DN_LIBPNG
sh ./configure \
    --host="$CFG_HOST" --build="$CFG_HOST" --prefix="$CFG_PREFIX" \
    CFLAGS="$CFG_OPTIMS -m32" \
    CPPFLAGS="-I$CFG_PREFIX/include" \
    LDFLAGS="-L$CFG_PREFIX/lib -m32"
make clean
make
make install-strip
cd ..

#
# build and install GLEW
#
cd $DN_GLEW
make \
    SYSTEM="mingw" \
    clean
make \
    SYSTEM="mingw" \
    POPT="$CFG_OPTIMS" \
    CFLAGS.EXTRA="-m32" \
    LDFLAGS.EXTRA="-m32"
make \
    SYSTEM="mingw" \
    GLEW_DEST="" \
    DESTDIR="$CFG_PREFIX" \
    install
cd ..

#
# build and install SDL
#
cd $DN_SDL
sh ./configure \
    --host="$CFG_HOST" --build="$CFG_HOST" --prefix="$CFG_PREFIX" \
    --enable-assembly=off \
    CFLAGS="$CFG_OPTIMS -m32" \
    CPPFLAGS="-DSDL_ASSERT_LEVEL=0" \
    LDFLAGS="-m32"
make clean
make
make install
strip "$CFG_PREFIX/bin/SDL2.dll"
cd ..

#
# build and install SDL_image
#
cd $DN_SDLIMG
sh ./configure \
    --host="$CFG_HOST" --build="$CFG_HOST" --prefix="$CFG_PREFIX" \
    CFLAGS="$CFG_OPTIMS -m32" \
    CPPFLAGS="-I$CFG_PREFIX/include -DSDL_ASSERT_LEVEL=0" \
    LDFLAGS="-L$CFG_PREFIX/lib -m32"
make clean
make
make install-strip
cd ..

#
# build and install PhysFS
#
cd $DN_PHYSFS
cmake \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_CXX_FLAGS="-m32" \
    -DCMAKE_C_FLAGS="-m32" \
    -DCMAKE_CXX_FLAGS_RELEASE="$CFG_OPTIMS -DNDEBUG" \
    -DCMAKE_C_FLAGS_RELEASE="$CFG_OPTIMS -DNDEBUG" \
    -DCMAKE_INSTALL_PREFIX="$CFG_PREFIX" \
    -G "MSYS Makefiles"
make clean
make
make install/strip
cd ..

#
# build and install TinyXML
#
cd $DN_TINYXML
cmake \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_CXX_FLAGS="-m32" \
    -DCMAKE_C_FLAGS="-m32" \
    -DCMAKE_CXX_FLAGS_RELEASE="$CFG_OPTIMS -DNDEBUG" \
    -DCMAKE_C_FLAGS_RELEASE="$CFG_OPTIMS -DNDEBUG" \
    -DCMAKE_INSTALL_PREFIX="$CFG_PREFIX" \
    -G "MSYS Makefiles"
make clean
make
make install/strip
cd ..

#
# build trigger-rally
#
cd "$DN_TRIGGER/src"
make -f GNUmakefile.MSYS clean
make -f GNUmakefile.MSYS64 clean
make OPTIMS="$CFG_OPTIMS" -f GNUmakefile.MSYS
make OPTIMS="$CFG_OPTIMS" -f GNUmakefile.MSYS winclean
cd ../..
