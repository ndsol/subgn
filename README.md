# [gn meta-build system](https://github.com/ndsol/subgn) [![CI Status](https://travis-ci.org/ndsol/subgn.svg?branch=master)](https://travis-ci.org/ndsol/subgn)

Actually this is "sub"gn.
subgn:gn::[subninja](https://github.com/ndsol/subninja):ninja.

> GN is a meta-build system that generates
[NinjaBuild](https://ninja-build.org/) files so that you can build
~~Chromium~~ anything you want with Ninja.

The official **gn** is
[here](https://chromium.googlesource.com/chromium/src/tools/gn/). This repo
tracks the official repo with a few minor additional features.

### So is this a fork then?

Yeah, sure. Since "official gn" lives on chromium.googlesource.com, this repo
doesn't bother to clone all git commits. The history has been squashed.

Patches are kept to an absolute minimum. No changes here should ever cause a
build to fail which works with "official gn."

# Building gn

To build `out_bootstrap/gn`, type:
```
git clone https://github.com/ndsol/subgn
subgn/build.cmd
```

### How to replicate what is here

[Build instructions](https://gist.github.com/mohamed/4fa7eb75807463d4dfa3)
(semi-official?) from 2015:
```
#!/bin/bash

set -e
set -v

# Get the sources
mkdir gn-standalone
cd gn-standalone
mkdir tools
cd tools
git clone https://chromium.googlesource.com/chromium/src/tools/gn
cd ..
mkdir -p third_party/libevent
cd third_party/libevent
wget --no-check-certificate https://chromium.googlesource.com/chromium/chromium/+archive/master/third_party/libevent.tar.gz
tar -xvzf libevent.tar.gz
cd ../..
git clone https://chromium.googlesource.com/chromium/src/base
git clone https://chromium.googlesource.com/chromium/src/build
git clone https://chromium.googlesource.com/chromium/src/build/config
mkdir testing
cd testing
git clone https://chromium.googlesource.com/chromium/testing/gtest
cd ..

# Build
cd tools/gn
./bootstrap/bootstrap.py -s
```

The applied patch set is included as [subgn.patch](subgn.patch).
