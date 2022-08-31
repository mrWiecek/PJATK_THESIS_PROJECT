resource_group_name="RG-TERRAFORM-PROVISIONG"
storage_account_name="stterraformprovisioning2"

echo "Setting access key variable ..."
export ARM_ACCESS_KEY=$(az storage account keys list --resource-group $resource_group_name --account-name $storage_account_name --query '[0].value' -o tsv)
echo "All set up"
az login
az account set -s "5b6e9d1b-7336-4efc-80a9-a4970b5c5eb5"
