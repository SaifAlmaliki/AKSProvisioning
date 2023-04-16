terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group along with its required parameters.
resource "azurerm_resource_group" "aks-rg" {
  name     = "aksRG"
  location = "West Europe"
  tags = {
    Environment = "Dev",
    Owner="saif.almaliki@pwc.com"
  }
}

# Kubernetes  Cluster
# The 'k8sCluster' is the locally given name for that resource that is only to be used as a reference inside the scope of the module.
# The name and dns_prefix are used to define the cluster's name and DNS name
resource "azurerm_kubernetes_cluster" "k8sCluster" {
  name = "${var.cluster_name}-${var.env_name}"
  location = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix = "k8sCluster"
  tags = azurerm_resource_group.aks-rg.tags

  # Enable the Ingress controller for the AKS cluster.
  # This flag installs Ingress Nginx and also installs the ExternalDNS that can be used to manage DNS entries automatically.
  http_application_routing_enabled = true

  # In the 'default_node_pool' you are defining the specs for the worker nodes.
  default_node_pool {
    name = "default"
    node_count = 2
    vm_size = "standard_d2_v2"
  }
  # define the type of the identity, which is 'SystemAssigned'.
  # This means that Azure will automatically create the required roles and permissions,
  # and you won't need to manage any credentials.
  identity {
    type = "SystemAssigned"
  }
}


# Modify the cluster by Adding another - more memory-optimized node pool to your cluster for your memory-hungry applications.
resource "azurerm_kubernetes_cluster_node_pool" "memoryOptimizedPoll" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8sCluster.id
  name = "memoryopt"
  node_count = 1
  vm_size = "standard_d11_v2"
}







/*

# Azure Virtual Network
resource "azurerm_virtual_network" "mtc-vn" {
  name                = "mtc-network"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    Environment = "dev"
  }
}

# Network Subnet
resource "azurerm_subnet" "mtc-subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "mtc-sg" {
  name                = "mtc-sg"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  tags = {
    Environment = "Dev"
  }
}

# Network Security Rule
resource "azurerm_network_security_rule" "mtc-dev-rule" {
  name                        = "mtc-dev-rule1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-sg.name

}

# Network Security Group
resource "azurerm_subnet_network_security_group_association" "mtc-sga" {
  subnet_id                 = azurerm_subnet.mtc-subnet.id
  network_security_group_id = azurerm_network_security_group.mtc-sg.id
}

# public IP Address
resource "azurerm_public_ip" "mtc-ip" {
  name                = "mtc-ip"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Dynamic"
  tags = {
    Environment = "Dev"
  }
}

# Network Interface card
resource "azurerm_network_interface" "mtc-nic" {
  name                = "mtc-nic"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc-ip.id
  }

  tags = {
    Environmenrt = "Dev"
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "mtc-vm" {
  name                  = "mtc-vm"
  resource_group_name   = azurerm_resource_group.mtc-rg.name
  location              = azurerm_resource_group.mtc-rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.mtc-nic.id]

  # Provision Ubuntu vm with custom code (Install docker)
  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

#  provisioner "local-exec" {
#    command = templatefile("${var.host_os}-ssh-script.tpl", {
#      hostname = self.public_ip_address,
#      user = "adminuser",
#      identityfile ="~/.ssh/mtcazuirekey"
#    })
#    # Conditional Expression
#    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash","-c"]
#  }

}

# (Data Source) Query the IP address
# 'data' not a resource, so doesn't need to apply but to refresh
data "azurerm_public_ip" "mtc-ip-data" {
  name                = azurerm_public_ip.mtc-ip.name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

# Get the vm name and public IP Address
output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc-vm.name} : ${data.azurerm_public_ip.mtc-ip-data.ip_address}"
}

*/