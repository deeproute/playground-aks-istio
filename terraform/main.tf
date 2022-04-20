resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                    = var.cluster_name
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    dns_prefix              = var.cluster_name
    kubernetes_version      = var.kubernetes_version
    private_cluster_enabled = var.private_cluster_enabled

    # linux_profile {
    #     admin_username = "ubuntu"

        # ssh_key {
        #     key_data = file(var.ssh_public_key)
        # }
    # }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.node_count
        vm_size         = var.vm_size
    }

    identity {
        type = "SystemAssigned"
    }

    # addon_profile {
    #     oms_agent {
    #         enabled                    = true
    #         log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    #     }
    # }

    network_profile {
        load_balancer_sku = "standard"
        network_plugin = "kubenet"
    }

    tags = {
        Environment = "lab"
    }
}