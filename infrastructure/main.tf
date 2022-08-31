data "azurerm_client_config" "current" {}

# create a resource group
resource "azurerm_resource_group" "dcoe_rg" {
  name     = "RG-${var.resource_group_name_base}"
  location = var.location
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  location            = azurerm_resource_group.dcoe_rg.location
  resource_group_name = azurerm_resource_group.dcoe_rg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = var.agent_count
    vm_size         = var.vm_size
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${replace(lower(var.resource_group_name_base), "-", "")}"
  resource_group_name = azurerm_resource_group.dcoe_rg.name
  location            = azurerm_resource_group.dcoe_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Storage account for AKS cluster
resource "azurerm_storage_account" "storageac" {
  name                     = "st${replace(lower(var.resource_group_name_base), "-", "")}"
  resource_group_name      = azurerm_kubernetes_cluster.k8s.node_resource_group
  location                 = azurerm_resource_group.dcoe_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_user_assigned_identity" "identity" {
  name                = "${azurerm_kubernetes_cluster.k8s.name}-agentpool"
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = data.azurerm_user_assigned_identity.identity.principal_id
  skip_service_principal_aad_check = true
}


#TODO This is not working properly yet,
# Needs a way to authenticate Azure Kubernetes Cluster with container registry
# See https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks

# resource "random_string" "password" {
#   length = 32
# }

# resource "azurerm_azuread_service_principal" "service_principal" {
#   application_id = "${azurerm_kubernetes_cluster.k8s.id}"
#}

# resource "azurerm_azuread_service_principal_password" "service_principal" {
#   service_principal_id = "${azurerm_azuread_service_principal.service_principal.id}"
#   value                = "${random_string.password.result}"
#   end_date             = "2020-01-01T01:02:03Z"
# }

//resource "azurerm_role_assignment" "acr-assignment" {
//  scope                = "${azurerm_container_registry.acr.id}"
//  role_definition_name = "Reader"
//  principal_id         = "${azurerm_azuread_service_principal.service_principal.application_id}"
//  depends_on           = ["azurerm_azuread_service_principal.service_principal"]
//}had

# output "object_id" {
#   description = "The Object ID for the Service Principal."
#   value       = "${azurerm_azuread_service_principal.service_principal.id}"
# }

# output "password" {
#   description = "The Password for this Service Principal."
#   value       = "${azurerm_azuread_service_principal_password.service_principal.value}"
# }

# # Storage account for AKS cluster
# resource "azurerm_storage_account" "jenkinsstorageac" {
#   name                     = "${replace(azurerm_resource_group.jenkins_rg_name.name, "_","")}jstoracc"
#   resource_group_name      = "${azurerm_resource_group.jenkins_rg_name.name}"
#   location                 = "${azurerm_resource_group.jenkins_rg_name.location}"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   tags {
#     environment = "jenkins"
#   }
# }

# resource "azurerm_virtual_network" "jenkinsvn" {
#   name                = "${format("%s-%s", var.jenkins_rg_name, "vnet")}"
#   address_space       = ["10.0.0.0/16"]
#   location            = "${var.location}"
#   resource_group_name = "${azurerm_resource_group.jenkins_rg_name.name}"

#   tags {
#     environment = "jenkins"
#   }
# }

# resource "template_dir" "azure_file_sc" {
#   source_dir      = "${path.module}/templates"
#   destination_dir = "${path.cwd}/rendered"

#   vars = {
#     storage_account = azurerm_storage_account.storageac.name
#   }
# }

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  sensitive = true
}

output "container_registry_name" {
  value = azurerm_container_registry.acr.name
  sensitive= false
}

output "storage_account_name" {
  value = azurerm_storage_account.storageac.name
  sensitive= false
}
