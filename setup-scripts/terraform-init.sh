export CWD=$(pwd)

function doVars {
  source ${CWD}/setup-scripts/variables/${BUILD_STAGE}.sh
}

function terraformInit {
  terraform -chdir=${CWD}/infrastructure/terraform init \
  -backend-config="bucket=devvincent-dev-terraform-state" \
  -backend-config="key=eu-west-1/aws-csv-to-json/production/terraform.tfstate" \
  -backend-config="region=eu-west-1"

  if [[ $? == 1 ]]; then echo "Terraform init failed, exit code 1" && exit 1; fi
}

doVars
terraformInit