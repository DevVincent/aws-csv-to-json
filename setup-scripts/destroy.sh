export CWD=$(pwd)

function doVars {
  source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh
}

function destroyTerraform {
  rm -f ${CWD}/.terraform/terraform.tfstate

  terraform -chdir=${CWD}/infrastructure/terraform init \
    -backend-config="bucket=${S3_TERRAFORM_STATE_BUCKET}" \
    -backend-config="key=$S3_TERRAFORM_STATE_KEY_PREFIX/${SERVICE}/${STAGE}.tfstate" \
    -backend-config="region=${S3_TERRAFORM_STATE_REGION}"

  terraform -chdir=${CWD}/infrastructure/terraform destroy -auto-approve

  rm ${CWD}/infrastructure/terraform-state.json
}

function destroyApp {
  if [ ${BUILD_STAGE} == "development" ]; then
    return $1
  fi

  npm run serverless -- remove --stage ${STAGE} --region ${REGION}
  aws s3 rm s3://$(cat ${CWD}/infrastructure/terraform-state.json | jq -r '.s3_bucket') --recursive
}

doVars
destroyApp
destroyTerraform
rm ${CWD}/deployed.${BUILD_STAGE}.lock
