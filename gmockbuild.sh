#!/bin/bash

# Configuration
os=$(uname -s)
case $os in
    "Darwin")
        lib_suffix="dylib"
        ;;
    "Linux")
        lib_suffix="so"
        ;;
    ?)
        echo "Platform $os not supported"
        exit 1
        ;;
esac

# Defaults
gmock_version='1.7.0'
workdir=$(mktemp -d /tmp/tmp.XXXXX)
prefix=/usr/local
shared="yes"
update_ldconf=false

function usage
{
    cat <<EOF
Usage: $0 [options]

-h              print this help message.
-v <version>    gmock version to build (Default: $gmock_version)
-p <path>       provide installation prefix path (Default: $prefix).
-s              build static libraries, default is shared.
-l              update ldconfig cache to include <prefix>/lib path.
                Option is ignored if -s is present.
                (Requires root privileges).
EOF
}

# Options parsing
while getopts "hv:p:sl" OPTION
do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        v)
            gmock_version=$OPTARG
            ;;
        p)
            prefix=$OPTARG
            ;;
        s)
            shared="no"
            lib_suffix="a"
            ;;
        l)
            update_ldconf=true
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

# Get GoogleMock sources
curl https://googlemock.googlecode.com/files/gmock-$gmock_version.zip > $workdir/gmock-$gmock_version.zip || exit 1
unzip -d $workdir $workdir/gmock-$gmock_version.zip || exit 1
gmocksrcdir=$workdir/gmock-$gmock_version

# Apply patch if available
gmock_patch="$(pwd)/patches/gmock-$gmock_version.patch"
if [ -f "$gmock_patch" ]; then
    pushd $gmocksrcdir
    patch -p0 -i $gmock_patch
    popd
fi

# Build shared libraries
cd $gmocksrcdir
mkdir build && cd build
local cmake_options=""
if [ "$shared" == "yes" ]; then
   cmake_options="-DBUILD_SHARED_LIBS=ON"
fi
cmake $cmake_options ..
make

# Install
subdirs=( include lib )
for subdir in "${subdirs[@]}"
do
    test -d $prefix/$subdir || mkdir -p $prefix/$subdir
done
find . -name "lib*.$lib_suffix" -exec cp {} $prefix/lib/ \;

includes=( $gmocksrcdir/include $gmocksrcdir/gtest/include )
for inc in "${includes[@]}"
do
    cp -r $inc/* $prefix/include/
done

# Remove workspace directory
rm -rf $workdir

# Update ldconfig cache
if [ "$shared" == "yes" -a "$update_ldconf" == "true" ]; then
    ldconf_dir="$prefix/lib"
    grep $ldconf_dir /etc/ld.so.conf
    if [ "$?" -ne "0" ]; then
        echo $ldconf_dir >> /etc/ld.so.conf
    fi
    ldconfig
fi

