terraform {
  backend "azurerm" {
    subscription_id      = "5b6e9d1b-7336-4efc-80a9-a4970b5c5eb5"
    resource_group_name  = "RG-TERRAFORM-PROVISIONG"
    storage_account_name = "stterraformprovisioning2"
    container_name       = "poc-kubeflow"
    key                  = "poc-kubeflow.tfstate"
  }
  # required_providers {
  #   azurerm = {
  #     source  = "hashicorp/azurerm"
  #     version = ">=3.20.0"
  #   }
  # }
}

provider "azurerm" {
  features {}
}
