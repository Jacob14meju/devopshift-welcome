output "vm_public_ip" {
  value = azurerm_public_ip.jacob.ip_address
  depends_on = [ time_sleep.wait_for_ip ]
  description = "public ip addrres"
}