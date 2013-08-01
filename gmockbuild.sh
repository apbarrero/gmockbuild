#!/bin/bash

gmock_version='1.6.0'
gmocksrcdir=$(mktemp -u -d)
prefix=/usr/local

function usage
{
    cat <<EOF
Usage: $0 [options]

-h            print this help message.
-p <path>     provide installation prefix path (Default: $prefix).
EOF
}

# Options parsing
while getopts "hp:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        p)
            prefix=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

# Get GoogleMock sources
svn export http://googlemock.googlecode.com/svn/tags/release-$gmock_version $gmocksrcdir
if [ "$?" -ne "0" ]; then
    exit 1
fi

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
cmake -DBUILD_SHARED_LIBS=ON ..
make

# Install
subdirs=( include lib )
for subdir in "${subdirs[@]}"
do
    test -d $prefix/$subdir || mkdir -p $prefix/$subdir
done
find . -name "lib*.so" -exec cp {} $prefix/lib/ \;

includes=( $gmocksrcdir/include $gmocksrcdir/gtest/include )
for inc in "${includes[@]}"
do
    cp -r $inc/* $prefix/include/
done

# Remove sources
rm -rf $gmocksrcdir

