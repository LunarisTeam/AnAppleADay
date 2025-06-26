#!/bin/bash
#
# Copyright 2025 Lunaris Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ---------------------------------------------------------------------------
#

if [[ -z "${SDKROOT}" || -z "${SCRIPTPATH}" || -z "$PARALLEL" ]]; then
    exit 1
fi

cd "$SCRIPTPATH"

if [ ! -d "vtk-src" ]; then
    git clone https://gitlab.kitware.com/vtk/vtk.git vtk-src
fi

mkdir -p vtk-src/build-ct

SDKROOT=$(xcrun --sdk macosx --show-sdk-path) \
cmake -GNinja \
    -S "$SCRIPTPATH/vtk-src" \
    -B "$SCRIPTPATH/vtk-src/build-ct" \
    -DVTK_BUILD_COMPILE_TOOLS_ONLY=ON \
    -DCMAKE_INSTALL_PREFIX="$SCRIPTPATH/vtk-compiletools"

mkdir "$SCRIPTPATH/vtk-compiletools"

cmake --build "$SCRIPTPATH/vtk-src/build-ct" \
      --parallel $PARALLEL \
      --config Release \
      --target install

