export CWD=$(pwd)

function createTerraformBucket {
  aws s3api create-bucket \
    --bucket ${S3_TERRAFORM_STATE_BUCKET} \
    --region ${S3_TERRAFORM_STATE_REGION} \
    --create-bucket-configuration LocationConstraint=${S3_TERRAFORM_STATE_REGION}
}

function doVars {
  source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh
}

function deployTerraform {
  rm -f ${CWD}/.terraform/terraform.tfstate

  if [[ $1 == "plan" ]]; then
    terraform -chdir=${CWD}/infrastructure/terraform plan -detailed-exitcode
    if [[ $? == 1 ]]; then echo "Terraform plan failed, exit code 1" && exit 1; fi
  else
    terraform -chdir=${CWD}/infrastructure/terraform apply -auto-approve -no-color
    if [[ $? == 1 ]]; then echo "Terraform apply failed, exit code 1" && exit 1; fi
  fi

  terraform -chdir=${CWD}/infrastructure/terraform output -json | jq 'with_entries(.value |= .value)' > ${CWD}/infrastructure/terraform-state.json
}

if [ ! -f ${CWD}/deployed.${BUILD_STAGE}.lock ]; then
  doVars
  createTerraformBucket
  deployTerraform
  touch ${CWD}/deployed.${BUILD_STAGE}.lock
fi

doVars
deployTerraform
