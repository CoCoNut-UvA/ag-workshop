# Attribute Grammar workshop
This repository contains the optional assignment part of the attribute grammar workshop.

## Getting started
Run the configure script first:
```bash
./configure.sh
```
If everything went correctly, a build-debug directory is created.
Run
```bash
make -C build-debug
```
to build your compiler.

## Creating an archive
You can quickly create an archive for submitting to canvas as follows
```bash
make dist
```
this gets everything in your git repo and combines it with the used coconut version in one archive.
This should contain everything needed to hand in your assignments.
**NOTE:** Always check the resulting archive if it contains everything and builds correctly.
