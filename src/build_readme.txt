================================================================================
ReadMe for Trigger Rally build scripts                                   0.6.6.1
================================================================================

0. Purpose, author, license
1. Requirements
2. Walkthrough
3. Optimization

--------------------------------------------------------------------------------
0. Purpose, author, license
--------------------------------------------------------------------------------

These scripts will automate the building of Trigger Rally on Windows 64-bit,
using MSYS2.

Written by Andrei Bondor and dedicated to the Public Domain.

--------------------------------------------------------------------------------
1. Requirements
--------------------------------------------------------------------------------

Platform and tools required:

 * Windows 64-bit (Windows 7 or later)
 * MSYS2
    https://www.msys2.org/
 * CMake
    https://cmake.org/download/

Development libraries required:

 * FMOD Studio API 1.06.XX
    http://www.fmod.org/browse-studio-api/#FMODStudio106
 * GLEW 2.X
    http://sourceforge.net/projects/glew/files/glew/
 * PhysFS
    http://icculus.org/physfs/downloads/
 * SDL2 2.X.X
    http://www.libsdl.org/download-2.0.php
 * SDL2_image 2.X.X
    http://www.libsdl.org/projects/SDL_image/
 * libjpeg
    http://ijg.org/
 * libpng
    http://libpng.org/pub/png/libpng.html
 * zlib
    http://zlib.net/
 * TinyXML-2 7.x.x
    https://github.com/leethomason/tinyxml2/releases

--------------------------------------------------------------------------------
2. Walkthrough
--------------------------------------------------------------------------------

Download all the required tools and development libraries listed above.
Prefer the 64-bit versions of tools, if available.
Prefer the .TAR.GZ archives of development libraries, if available.

Install MSYS2. After installation is complete you may need to install extra
tools within it: gcc, g++, make, zip.
This is done by starting the MSYS2 shell and using the pacman utility:

    $ pacman -S mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain
    $ pacman -S make
    $ pacman -S zip

Install CMake. Its binaries must be usable by MSYS2: this can be done simply by
adding CMake's bin/ to the PATH (option shown at the end of CMake setup) and
then setting MSYS2 to inherit paths from the system: edit the configuration
files "mingw32.ini" and "mingw64.ini" at "MSYS2_PATH_TYPE=inherit".

Install the FMOD Studio API to its default folder, which should be:

    "C:\Program Files (x86)\FMOD SoundSystem\FMOD Studio API Windows"

Extract the other libraries to the MSYS2 user's home folder, which should be:

    "C:\msys64\home\UserName"

Extract the Trigger Rally .TAR.GZ distribution there.
Copy these build scripts next to the extracted libraries.

The directory structure should now be similar to:

    $ pwd
    /home/UserName
    $ ls -1 --group-directories-first
    glew-2.1.0
    jpeg-9c
    libpng-1.6.36
    physfs-3.0.1
    SDL2_image-2.0.4
    SDL2-2.0.9
    tinyxml2-7.0.1
    trigger-rally-0.6.6.1
    zlib-1.2.11
    build_32bit.sh
    build_64bit.sh
    build_readme.txt

Read the build scripts and make sure the "Directory Name" DN_* variables
correspond to the development libraries you have.
Once that is done, you can open the MSYS2 shell and run one of the
build scripts, depending on the architecture:

    $ #
    $ # for 32-bit build
    $ #
    $ ./build_32bit.sh

    $ #
    $ # for 64-bit build
    $ #
    $ ./build_64bit.sh

The build process has started and will typically run for a couple of minutes.

--------------------------------------------------------------------------------
3. Optimization
--------------------------------------------------------------------------------

If you build the game only for yourself, then you should edit the build scripts
to use native optimization for best performance on your machine:

    CFG_OPTIMS="-march=native -mtune=native -Ofast"

The same settings should be reused for the PhysFS build.
