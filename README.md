gmockbuild
==========

Script to build and install [Google Mock](https://code.google.com/p/googlemock/) library

## Requirements ##

* [curl](http://curl.haxx.se/) to download sources.
* [cmake](http://www.cmake.org/) >= 2.6.2 to generate platform specific Makefiles.
* A native C++ compiler for your platform.

## Usage ##

```shell
git clone https://github.com/apbarrero/gmockbuild.git
cd gmockbuild && ./gmockbuild.sh
```

Default installation prefix is `/usr/local` so you may require root privileges to run the script.
Use option `-p <prefix path>` to install somewhere else.

For details on script options just run:

```shell
./gmockbuild.sh -h
```

## Tested platforms ##

* Ubuntu 13.04, curl 7.29.0, cmake 2.8.10.1, gcc 4.7.3
