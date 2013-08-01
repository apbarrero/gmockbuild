#!/bin/bash

gmock_version='1.6.0'
gmocksrcdir=$(mktemp -u -d)
prefix=/usr/local

# Get GoogleMock sources
svn export http://googlemock.googlecode.com/svn/tags/release-$gmock_version $gmocksrcdir
if [ "$?" -ne "0" ]; then
    exit 1
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

