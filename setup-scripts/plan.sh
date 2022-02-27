export CWD=$(pwd)

function doVars {
  source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh
}

function terraformInit {
  terraform -chdir=${CWD}/infrastructure/terraform init \
  -backend-config="bucket=${S3_TERRAFORM_STATE_BUCKET}" \
  -backend-config="key=${S3_TERRAFORM_STATE_KEY_PREFIX}/terraform.tfstate" \
  -backend-config="region=${S3_TERRAFORM_STATE_REGION}"
}

function planTerraform {
  rm -f ${CWD}/.terraform/terraform.tfstate

  terraformInit

  terraform -chdir=${CWD}/infrastructure/terraform plan
  terraform -chdir=${CWD}/infrastructure/terraform output -json | jq 'with_entries(.value |= .value)' > ${CWD}/infrastructure/terraform-state.json
}

doVars
planTerraform