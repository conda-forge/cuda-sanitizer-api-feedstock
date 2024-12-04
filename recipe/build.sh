#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
# ${PREFIX}/lib should exist but create it in case it does not
mkdir -p lib

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

# Remove 32bit libraries
[[ -d "compute-sanitizer/x86" ]] && rm -rf compute-sanitizer/x86/

for i in `ls`; do
    [[ $i == "build_env_setup.sh" ]] && continue
    [[ $i == "conda_build.sh" ]] && continue
    [[ $i == "metadata_conda_debug.yaml" ]] && continue

    cp -rv $i ${PREFIX}

    if [[ $i == "compute-sanitizer" ]]; then
        for j in `ls $i`; do
            [[ -d $PREFIX/$i/$j ]] && continue

            if [[ $j == "compute-sanitizer" || $j == "TreeLauncherSubreaper" || $j == "TreeLauncherTargetLdPreloadHelper" ]]; then
                echo patchelf --force-rpath --set-rpath "\$ORIGIN/../lib:\$ORIGIN/../${targetsDir}/lib" $PREFIX/$i/$j
                patchelf --force-rpath --set-rpath "\$ORIGIN/../lib:\$ORIGIN/../${targetsDir}/lib" $PREFIX/$i/$j
            elif [[ $j =~ \.so($|\.) ]]; then
                echo patchelf --force-rpath --set-rpath '$ORIGIN/../lib:$ORIGIN/../${targetsDir}/lib' $PREFIX/$i/$j
                patchelf --force-rpath --set-rpath "\$ORIGIN/../lib:\$ORIGIN/../${targetsDir}/lib" $PREFIX/$i/$j
                mkdir -p ${PREFIX}/$i
                # Shared libraries are symlinked in $PREFIX/lib
                ln -svf ${PREFIX}/$i/$j ${PREFIX}/lib/$j
            fi
        done
    fi
done
