export CWD=$(pwd)

export REGION=eu-west-1

export AWS_DEFAULT_REGION=${REGION}

export SERVICE=$(cat $CWD/package.json | jq -r '.name')
export NAME="snoop"
export STAGE=$BUILD_STAGE

export TF_VAR_STAGE=${STAGE}
export TF_VAR_SERVICE=${NAME}
export TF_VAR_REGION=${REGION}

if [ -f ${CWD}/infrastructure/serverless-state.json ]; then
  export TF_VAR_API_GATEWAY_DOMAIN=$(cat ${CWD}/infrastructure/serverless-state.json | jq -r '.apiURL')
fi

export S3_TERRAFORM_STATE_BUCKET=devvincent-dev-terraform-state
export S3_TERRAFORM_STATE_KEY_PREFIX=${REGION}/${SERVICE}/${STAGE}/terraform
export S3_TERRAFORM_STATE_REGION=eu-west-1
