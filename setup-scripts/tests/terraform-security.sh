#!/bin/bash
export CWD=$(pwd)

function doVars {
  source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh
}

function terraformInit {
  terraform init \
  -backend-config="bucket=${S3_TERRAFORM_STATE_BUCKET}" \
  -backend-config="key=${S3_TERRAFORM_STATE_KEY_PREFIX}/${SERVICE}/${STAGE}.tfstate" \
  -backend-config="region=${S3_TERRAFORM_STATE_REGION}" ${CWD}/infrastructure/terraform
}

doVars
# terraformInit

if ! command -v tfsec &> /dev/null
then
	echo TFSec Could not be found - using docker
  docker run --rm -it -v "$(pwd)/infrastructure/terraform/:/src" liamg/tfsec /src
else
	tfsec ./infrastructure/terraform/
fi



LINT_CODE=$?

if [[ $status -eq 0 && $TF_SEC_TEST_ALLOW_FAIL ]]
then
	echo TF Sec Lint Completed
else
	exit $LINT_CODE
fi