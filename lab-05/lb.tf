resource "azurerm_public_ip" "lb_pip" {
   name                = "lb-pip-${var.yourname}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_lb" "lb" {
  name = "${var.youname}-lb"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku = "Standard"
  frontend_ip_configuration {
    name = "lb_front"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_back" {
  name = "lb-backpool-${var.yourname}"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb-prob" {
  name = "lb-${var.yourname}-prob"
  loadbalancer_id = azurerm_lb.lb.id
  port = 80
  protocol = "Http"
  request_path = "./welcome.html"
  interval_in_seconds = 15
  number_of_probes = 3
}

resource "azurerm_lb_rule" "lb-rule" {
  name = "${var.yourname}-lb-rule"
  loadbalancer_id = azurerm_lb.lb.id
  protocol = "Tcp"
  backend_port = 80
  frontend_port = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration.name
  backend_address_pool_ids = azurerm_lb_backend_address_pool.lb_back.id
  probe_id = azurerm_lb_probe.lb-prob.id
}