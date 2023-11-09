#!/bin/bash

GITHUB_USERNAME=""
GITHUB_TOKEN=""

# Clone the local extensions desired
echo "[[[[ ckanext-civity ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-civity.git ${SRC_EXTENSIONS_DIR}/ckanext-civity
cd "${SRC_EXTENSIONS_DIR}"/ckanext-civity
git checkout main

echo "[[[[ ckanext-dcat ]]]]"
git clone https://github.com/CivityNL/ckanext-dcat.git $SRC_EXTENSIONS_DIR/ckanext-dcat
cd "$SRC_EXTENSIONS_DIR"/ckanext-dcat
git checkout v1.5.1-civity

echo "[[[[ ckanext-fairdatapoint ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-fairdatapoint.git ${SRC_EXTENSIONS_DIR}/ckanext-fairdatapoint
cd "${SRC_EXTENSIONS_DIR}"/ckanext-fairdatapoint
git checkout main

echo "[[[[ ckanext-harvest ]]]]"
git clone https://github.com/ckan/ckanext-harvest.git ${SRC_EXTENSIONS_DIR}/ckanext-harvest
cd "${SRC_EXTENSIONS_DIR}"/ckanext-harvest
git checkout v1.5.6

echo "[[[[ ckanext-healthri ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-healthri.git ${SRC_EXTENSIONS_DIR}/ckanext-healthri
cd "${SRC_EXTENSIONS_DIR}"/ckanext-healthri
git checkout main

echo "[[[[ ckanext-matomo ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-matomo.git ${SRC_EXTENSIONS_DIR}/ckanext-matomo
cd "${SRC_EXTENSIONS_DIR}"/ckanext-matomo
git checkout main

echo "[[[[ ckanext-oauth2 ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-oauth2.git ${SRC_EXTENSIONS_DIR}/ckanext-oauth2
cd "${SRC_EXTENSIONS_DIR}"/ckanext-oauth2
git checkout civity-py3

echo "[[[[ ckanext-pdfview ]]]]"
git clone https://github.com/ckan/ckanext-pdfview.git ${SRC_EXTENSIONS_DIR}/ckanext-pdfview
cd "${SRC_EXTENSIONS_DIR}"/ckanext-pdfview
git checkout 0.0.8

echo "[[[[ ckanext-portal ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-portal.git ${SRC_EXTENSIONS_DIR}/ckanext-portal
cd "${SRC_EXTENSIONS_DIR}"/ckanext-portal
git checkout main

echo "[[[[ ckanext-scheming ]]]]"
git clone https://github.com/CivityNL/ckanext-scheming.git ${SRC_EXTENSIONS_DIR}/ckanext-scheming
cd "${SRC_EXTENSIONS_DIR}"/ckanext-scheming
git checkout release-3.0.0-civity

echo "[[[[ ckanext-workflow ]]]]"
git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/CivityNL/ckanext-workflow.git ${SRC_EXTENSIONS_DIR}/ckanext-workflow
cd "${SRC_EXTENSIONS_DIR}"/ckanext-workflow
git checkout main



# Install any local extensions in the src_extensions volume
echo "Looking for local extensions to install..."
echo "Extension dir contents:"
ls -la $SRC_EXTENSIONS_DIR
for i in $SRC_EXTENSIONS_DIR/*
do
    if [ -d $i ];
    then

        if [ -f $i/pip-requirements.txt ];
        then
            pip install -r $i/pip-requirements.txt
            echo "Found requirements file in $i"
        fi
        if [ -f $i/requirements.txt ];
        then
            pip install -r $i/requirements.txt
            echo "Found requirements file in $i"
        fi
        if [ -f $i/dev-requirements.txt ];
        then
            pip install -r $i/dev-requirements.txt
            echo "Found dev-requirements file in $i"
        fi
        if [ -f $i/setup.py ];
        then
            cd $i
            python3 $i/setup.py develop
            echo "Found setup.py file in $i"
            cd $APP_DIR
        fi

        if [ -f $i/config-options.ini ];
        then
          # TODO add them to the config
#            pip install -r $i/dev-requirements.txt
            echo "Found config-options file in $i"
        fi

        # Point `use` in test.ini to location of `test-core.ini`
        if [ -f $i/test.ini ];
        then
            echo "Updating \`test.ini\` reference to \`test-core.ini\` for plugin $i"
            ckan config-tool $i/test.ini "use = config:../../src/ckan/test-core.ini"
        fi
    fi
done

# Set debug to true
echo "Enabling debug mode"
ckan config-tool $CKAN_INI -s DEFAULT "debug = true"

# Set up the Secret key used by Beaker and Flask
# This can be overriden using a CKAN___BEAKER__SESSION__SECRET env var
if grep -E "beaker.session.secret ?= ?$" ckan.ini
then
    echo "Setting beaker.session.secret in ini file"
    ckan config-tool $CKAN_INI "beaker.session.secret=$(python3 -c 'import secrets; print(secrets.token_urlsafe())')"
    JWT_SECRET=$(python3 -c 'import secrets; print("string:" + secrets.token_urlsafe())')
    ckan config-tool $CKAN_INI "api_token.jwt.encode.secret=${JWT_SECRET}"
    ckan config-tool $CKAN_INI "api_token.jwt.decode.secret=${JWT_SECRET}"
fi

# Update the plugins setting in the ini file with the values defined in the env var
echo "Loading the following plugins: $CKAN__PLUGINS"
ckan config-tool $CKAN_INI "ckan.plugins = $CKAN__PLUGINS"

# Update the config file with each extension config-options
echo "[ckanext-scheming] Setting up config-options"
ckan config-tool $CKAN_INI -s app:main \
    "scheming.dataset_schemas = ckanext.healthri:scheming/schemas/health_ri.json"\
    "scheming.presets = ckanext.scheming:presets.json"\
    "scheming.dataset_fallback = false"



# Update test-core.ini DB, SOLR & Redis settings
echo "Loading test settings into test-core.ini"
ckan config-tool $SRC_DIR/ckan/test-core.ini \
    "sqlalchemy.url = $TEST_CKAN_SQLALCHEMY_URL" \
    "ckan.datastore.write_url = $TEST_CKAN_DATASTORE_WRITE_URL" \
    "ckan.datastore.read_url = $TEST_CKAN_DATASTORE_READ_URL" \
    "solr_url = $TEST_CKAN_SOLR_URL" \
    "ckan.redis.url = $TEST_CKAN_REDIS_URL"

# Run the prerun script to init CKAN and create the default admin user
python3 prerun.py

# Run any startup scripts provided by images extending this one
if [[ -d "/docker-entrypoint.d" ]]
then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: Running init file $f"; . "$f" ;;
            *.py)     echo "$0: Running init file $f"; python3 "$f"; echo ;;
            *)        echo "$0: Ignoring $f (not an sh or py file)" ;;
        esac
        echo
    done
fi

# Start supervisord
supervisord --configuration /etc/supervisord.conf &

# Start the development server as the ckan user with automatic reload
su ckan -c "/usr/bin/ckan -c $CKAN_INI run -H 0.0.0.0"
