export CWD=$(pwd)
export NODE_ENV=development

export CONFIG_LOCATION=${CWD}/infrastructure/config.development.json
export TF_VAR_CONFIG_FILE_LOCATION=$CONFIG_LOCATION

source ${CWD}/setup-scripts/variables/global.sh
