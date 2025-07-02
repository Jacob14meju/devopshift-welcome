resource "azurerm_linux_virtual_machine" "Jacob_vm" {
  name = var.vm_name
  location = var.vm_location
  resource_group_name = "Jacob-rg1"
  size = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password
  os_disk {
    name              = "jacob-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  network_interface_ids = var.nic_id
  disable_password_authentication = false
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}