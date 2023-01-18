#!/bin/bash
set -euo pipefail

echo "Symlinking"
ln -s ~/decker/whole-program-debloat/src/debloat_rt/ics/ics.ll
ln -s ~/decker/whole-program-debloat/src/spec/2017/linker.py

echo "Building"
make all

echo "Running baseline"
./main_base
echo $?
echo

echo "Running whole-program-debloat version"
./main_wpd
echo $?
echo

echo "Success. Exiting."
