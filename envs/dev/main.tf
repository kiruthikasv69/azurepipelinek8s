provider "azurerm" {
  features {}
   subscription_id = "XXXXXX"
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-dev"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "devacr1234"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-dev-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "dev-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "kubernetes_deployment" "flask" {
  metadata {
    name = "flask-app"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "flask-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }
      spec {
        container {
          name  = "flask-container"
          image = "devacr1234.azurecr.io/flask-app:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name = "flask-service"
  }
  spec {
    selector = {
      app = "flask-app"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
