#!/bin/sh

if [ -f ".env" ]; then
    echo "Environment file already exists. You are responsible for updating it!"
else
    echo "Copying environment file from Civity template"
    cp .env.civity .env
fi

# Check if environment variable is set, else set it to a default
# Otherwise we get a ton of stuff in the root directory
if [[ -z "${SRC_EXTENSIONS_DIR}" ]]; then
    SRC_EXTENSIONS_DIR="./src"
    echo "Setting extensions directory to default: ${SRC_EXTENSIONS_DIR}"
fi

echo "[[[[ ckanext-civity ]]]]"
git clone --branch main git@github.com:CivityNL/ckanext-civity.git ${SRC_EXTENSIONS_DIR}/ckanext-civity
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-civity
# git checkout main

echo "[[[[ ckanext-dcat ]]]]"
git clone --branch v1.5.1-civity git@github.com:CivityNL/ckanext-dcat.git $SRC_EXTENSIONS_DIR/ckanext-dcat
# cd "$SRC_EXTENSIONS_DIR"/ckanext-dcat
# git checkout v1.5.1-civity

echo "[[[[ ckanext-fairdatapoint ]]]]"
git clone --branch main git@github.com:CivityNL/ckanext-fairdatapoint.git ${SRC_EXTENSIONS_DIR}/ckanext-fairdatapoint
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-fairdatapoint
# git checkout main

echo "[[[[ ckanext-harvest ]]]]"
git clone --branch v1.5.6 git@github.com:ckan/ckanext-harvest.git ${SRC_EXTENSIONS_DIR}/ckanext-harvest
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-harvest
# git checkout v1.5.6

echo "[[[[ ckanext-healthri ]]]]"
git clone --branch main git@github.com:CivityNL/ckanext-healthri.git ${SRC_EXTENSIONS_DIR}/ckanext-healthri
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-healthri
# git checkout main

echo "[[[[ ckanext-matomo ]]]]"
git clone --branch main git@github.com:CivityNL/ckanext-matomo.git ${SRC_EXTENSIONS_DIR}/ckanext-matomo
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-matomo
# git checkout main

echo "[[[[ ckanext-oauth2 ]]]]"
git clone --branch civity-py3 git@github.com:CivityNL/ckanext-oauth2.git ${SRC_EXTENSIONS_DIR}/ckanext-oauth2
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-oauth2
# git checkout civity-py3

echo "[[[[ ckanext-pdfview ]]]]"
git clone --branch 0.0.8 git@github.com:ckan/ckanext-pdfview.git ${SRC_EXTENSIONS_DIR}/ckanext-pdfview
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-pdfview
# git checkout 0.0.8

echo "[[[[ ckanext-portal ]]]]"
git clone --branch main git@github.com:CivityNL/ckanext-portal.git ${SRC_EXTENSIONS_DIR}/ckanext-portal
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-portal
# git checkout main

echo "[[[[ ckanext-scheming ]]]]"
git clone --branch release-3.0.0-civity git@github.com:CivityNL/ckanext-scheming.git ${SRC_EXTENSIONS_DIR}/ckanext-scheming
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-scheming
# git checkout release-3.0.0-civity

echo "[[[[ ckanext-workflow ]]]]"
git clone --branch main git@github.com:CivityNL/ckanext-workflow.git ${SRC_EXTENSIONS_DIR}/ckanext-workflow
# cd "${SRC_EXTENSIONS_DIR}"/ckanext-workflow
# git checkout main
