export CWD=$(pwd)
export NODE_ENV=production

export CONFIG_LOCATION=${CWD}/infrastructure/config.production.json
export TF_VAR_CONFIG_FILE_LOCATION=$CONFIG_LOCATION

source ${CWD}/setup-scripts/variables/global.sh
