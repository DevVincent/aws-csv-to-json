export CWD=$(pwd)

source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh

npm install --production=false
npm run build
