#!/usr/bin/env bash

# Use gtar if it exists because macOS tar does not support --concatenate
TAR="tar"
if command -v gtar &> /dev/null; then
    TAR="gtar"
fi

if ! [[ -z $(git status --porcelain) ]]; then
    echo "git status is not clean. Ensure it is before making an archive."
    echo "---------------------------------------------------------------"
    git status
    exit 1
fi

echo "----- Creating archive of your source ----"
cd coconut/
echo "Archiving CoCoNut..."
git archive --prefix="ag-workshop/coconut/" -o coconut.tar HEAD . || exit 1
cd ../
echo "Archiving ag-workshop..."
git archive --prefix="ag-workshop/" -o ag-workshop.tar HEAD . || exit 1
echo "Combining..."
$TAR --concatenate --file=ag-workshop.tar coconut/coconut.tar || exit 1
rm coconut/coconut.tar
echo "Compressing..."
gzip -9 ag-workshop.tar
echo "----- Finished ------"
echo "Always double check the created archive!"
