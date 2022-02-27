export CWD=$(pwd)

function doVars {
  source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh
}

function deployServerless {
  TF_STATE=$(cat ${CWD}/infrastructure/terraform-state.json)

  npm run webpack

  npm run serverless:bundle

  if [[ $1 == "plan" ]]; then
    npm run serverless -- package --stage ${STAGE} --region ${REGION}
  else
    npm run serverless -- deploy --stage ${STAGE} --region ${REGION}
  fi
}

doVars
deployServerless