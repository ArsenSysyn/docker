#!/bin/bash

git clone --recurse-submodules https://gerrit.googlesource.com/gerrit
cd gerrit && bazel build :release
