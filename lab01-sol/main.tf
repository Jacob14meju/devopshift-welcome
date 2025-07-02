provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "rg" {
  name = "Jacob-rg1"
  location = "East Us"
}

resource "azurerm_virtual_network" "Jacob-vn1" {
  name = "Jacob-vn1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub" {
  name = "Jacob-subnet"
  virtual_network_name = azurerm_virtual_network.Jacob-vn1.name
  resource_group_name = azurerm_resource_group.rg.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "jacob" {
  location = azurerm_resource_group.rg.location
  name = "Jacob-pub-ip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

resource "azurerm_network_interface" "Jacob-nic" {
  name = "Jacob-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  ip_configuration {
    name = "Jacob-conf"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.sub.id
    public_ip_address_id = azurerm_public_ip.jacob.id
  }
}

module "vm1" {
  source = "modules/vm"
  vm_name = "vm1"
  nic_id = azurerm_network_interface.Jacob-nic.id
}

resource "time_sleep" "wait_for_ip" {
  create_duration = "30"
}