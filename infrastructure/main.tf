data "azurerm_client_config" "current" {}

# create a resource group
resource "azurerm_resource_group" "dcoe_rg" {
  name     = "RG-${upper(var.project_name_base)}-${upper(var.environment)}"
  location = var.location
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.project_name_base}"
  location            = azurerm_resource_group.dcoe_rg.location
  resource_group_name = azurerm_resource_group.dcoe_rg.name
  dns_prefix          = var.project_name_base
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
  name                = "acr${replace(lower(var.project_name_base), "-", "")}"
  resource_group_name = azurerm_resource_group.dcoe_rg.name
  location            = azurerm_resource_group.dcoe_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Storage account for AKS cluster
resource "azurerm_storage_account" "storageac" {
  name                     = "st${replace(lower(var.project_name_base), "-", "")}"
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
