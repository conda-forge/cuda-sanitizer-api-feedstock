#!/bin/bash

# conda-forge/cuda-sanitizer-api-feedstock#39: patchelf <0.18 overwrote the protodesc_cold section.
# Without a GPU the sanitizer always exits non-zero, so check its output instead of the exit code.
output=$(compute-sanitizer --tool memcheck /bin/true 2>&1)
echo "${output}"

if grep -q "Check failed" <<< "${output}"; then
    echo "compute-sanitizer failed in an unexpected way"
    exit 1
fi
