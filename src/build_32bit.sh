#!/bin/bash
set -e

# Конфигурация
PREFIX="$HOME/trigger-win32-root"
SRC_DIR="$(pwd)"
BUILD_DIR="$SRC_DIR/build"
OPTIMS="-march=x86-64 -mtune=generic -O2"
HOST="x86_64-w64-mingw32"

export CC="${HOST}-gcc"
export CXX="${HOST}-g++"
export STRIP="${HOST}-strip"

# Библиотеки и их ссылки
declare -A LIBS=(
  [jpeg]="https://www.ijg.org/files/jpegsrc.v9c.tar.gz"
  [zlib]="https://zlib.net/fossils/zlib-1.2.11.tar.gz"
  [libpng]="https://download.sourceforge.net/libpng/libpng-1.6.36.tar.gz"
  [glew]="https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0.tgz"
  [sdl2]="https://www.libsdl.org/release/SDL2-2.0.9.tar.gz"
  [sdl2_image]="https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.4.tar.gz"
  [physfs]="https://icculus.org/physfs/downloads/physfs-3.0.1.tar.bz2"
  [tinyxml2]="https://github.com/leethomason/tinyxml2/archive/7.0.1.tar.gz"
)

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Скачиваем и распаковываем библиотеки
for lib in "${!LIBS[@]}"; do
  url="${LIBS[$lib]}"
  filename="${url##*/}"
  dirname="${filename%.tar.*}"
  echo "==> Обработка: $lib ($filename)"

  if [ ! -f "$filename" ]; then
    echo "   → Скачиваем $filename"
    wget -c "$url"
  fi

  if [ ! -d "$dirname" ]; then
    echo "   → Распаковываем $filename"
    case "$filename" in
      *.tar.gz|*.tgz) tar -xzf "$filename" ;;
      *.tar.bz2) tar -xjf "$filename" ;;
      *) echo "Неизвестный формат: $filename"; exit 1 ;;
    esac
  fi
done

echo "==> Всё скачано и распаковано."
echo "Теперь можно переходить к сборке библиотек..."

# Cross-compilation for Windows 64-bit from Linux

CFG_OPTIMS="-march=x86-64 -mtune=generic -O2"
CFG_HOST="x86_64-w64-mingw32"
CFG_PREFIX="$HOME/trigger-win64-root"  # изолированная папка для сборки и библиотек

# Названия архивов/папок с исходниками
DN_JPEG="jpeg-9c"
DN_ZLIB="zlib-1.2.11"
DN_LIBPNG="libpng-1.6.36"
DN_GLEW="glew-2.1.0"
DN_SDL="SDL2-2.0.9"
DN_SDLIMG="SDL2_image-2.0.4"
DN_PHYSFS="physfs-3.0.1"
DN_TINYXML="tinyxml2-7.0.1"
DN_TRIGGER="trigger-rally-code-r1019"

export CC="${CFG_HOST}-gcc"
export CXX="${CFG_HOST}-g++"
export STRIP="${CFG_HOST}-strip"

# Пример настройки libjpeg:
cd $DN_JPEG
./configure --host=$CFG_HOST --prefix=$CFG_PREFIX \
    CFLAGS="$CFG_OPTIMS -m64" LDFLAGS="-m64"
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
