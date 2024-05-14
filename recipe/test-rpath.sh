#!/bin/bash

errors=""

for bin in `find ${PREFIX}/bin -type f`; do
    [[ `basename "$bin"` != patchelf ]] || continue

    rpath=$(patchelf --print-rpath $bin)
    echo "$bin rpath: $rpath"
    if [[ "$rpath" != "" ]]; then
        errors+="$bin\n"
    fi
done

if [[ $errors ]]; then
    echo "The following binaries were found with an unexpected RPATH:"
    echo -e "$errors"

    exit 1
else
    exit 0
fi
