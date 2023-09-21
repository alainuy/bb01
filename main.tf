resource "azurerm_resource_group" "azurerm_resource_group_2" {
  tags     = merge(var.tags, {})
  name     = "test-rg"
  location = var.location
}

resource "azurerm_virtual_network" "azurerm_virtual_network_3" {
  tags                = merge(var.tags, {})
  resource_group_name = azurerm_resource_group.azurerm_resource_group_2.name
  name                = "test-Vnet"
  location            = var.location

  address_space = [
    "10.0.0.0/16",
  ]
}

resource "azurerm_subnet" "azurerm_subnet_4" {
  virtual_network_name = azurerm_virtual_network.azurerm_virtual_network_3.name
  resource_group_name  = azurerm_resource_group.azurerm_resource_group_2.name
  name                 = "subnet1"

  address_prefixes = [
    "10.0.1.0/24",
  ]
}

resource "azurerm_network_interface" "azurerm_network_interface_5" {
  tags                = merge(var.tags, {})
  resource_group_name = azurerm_resource_group.azurerm_resource_group_2.name
  name                = "NIC1"
  location            = var.location

  ip_configuration {
    subnet_id                     = azurerm_subnet.azurerm_subnet_4.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    name                          = "NIC1"
  }
}

resource "azurerm_network_security_group" "azurerm_network_security_group_6" {
  tags                = merge(var.tags, {})
  resource_group_name = azurerm_resource_group.azurerm_resource_group_2.name
  name                = "NSG1"
  location            = var.location

  security_rule {
    source_address_prefix      = "*"
    protocol                   = "Tcp"
    priority                   = 200
    name                       = "HTTP"
    direction                  = "Inbound"
    destination_address_prefix = "*"
    description                = "Allow-HTTP"
    access                     = "Allow"
    destination_port_ranges = [
      "80",
    ]
    source_port_ranges = [
      "80",
    ]
  }
}

resource "azurerm_resource_group" "azurerm_resource_group_7" {
  tags     = merge(var.tags, {})
  name     = "spoke"
  location = var.location
}

resource "azurerm_virtual_network" "azurerm_virtual_network_8" {
  tags                = merge(var.tags, {})
  resource_group_name = azurerm_resource_group.azurerm_resource_group_7.name
  name                = "spoke-vnet"
  location            = var.location

  address_space = [
    "172.16.50.0/24",
  ]
}

resource "azurerm_virtual_network_peering" "azurerm_virtual_network_peering_9" {
  virtual_network_name         = azurerm_virtual_network.azurerm_virtual_network_3.name
  resource_group_name          = azurerm_resource_group.azurerm_resource_group_2.name
  remote_virtual_network_id    = azurerm_virtual_network.azurerm_virtual_network_8.id
  name                         = "hub-to-spoke"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "azurerm_virtual_network_peering_10" {
  virtual_network_name         = azurerm_virtual_network.azurerm_virtual_network_8.name
  resource_group_name          = azurerm_resource_group.azurerm_resource_group_7.name
  remote_virtual_network_id    = azurerm_virtual_network.azurerm_virtual_network_3.id
  name                         = "spoke-to-hub"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_windows_virtual_machine" "azurerm_windows_virtual_machine_11" {
  tags                = merge(var.tags, {})
  size                = var.vm_family_size
  resource_group_name = azurerm_resource_group.azurerm_resource_group_2.name
  name                = "jumphost"
  location            = var.location
  admin_username      = "adminuser"
  admin_password      = azurerm_key_vault_secret.azurerm_key_vault_secret_14.value

  network_interface_ids = [
    azurerm_network_interface.azurerm_network_interface_5.id,
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    version   = "latest"
    sku       = "2016-Datacenter"
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
  }
}

data "azurerm_client_config" "azurerm_client_config_12" {
}

resource "azurerm_key_vault" "azurerm_key_vault_13" {
  tenant_id           = data.azurerm_client_config.azurerm_client_config_12.tenant_id
  tags                = merge(var.tags, {})
  sku_name            = "standard"
  resource_group_name = azurerm_resource_group.azurerm_resource_group_2.name
  name                = "demo"
  location            = var.location

  access_policy {
    tenant_id = data.azurerm_client_config.azurerm_client_config_12.tenant_id
    object_id = data.azurerm_client_config.azurerm_client_config_12.object_id
    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "List",
    ]
    storage_permissions = [
      "Get",
      "List",
    ]
  }
}

resource "azurerm_key_vault_secret" "azurerm_key_vault_secret_14" {
  value        = random_password.vmpassword.result
  tags         = merge(var.tags, {})
  name         = "adminpassword"
  key_vault_id = azurerm_key_vault.azurerm_key_vault_13.id
}

resource "random_password" "vmpassword" {

  length  = 64
  special = true
}

