# Convert the regional VM counts into individual VM instances,
# so Terraform can create a separate NIC and VM for each instance.
locals {
  vm_instances = merge([
    for region, data in var.regions : {
      for i in range(data.vm_count) :
      "${region}-${i + 1}" => {
        region   = region
        location = data.location
      }
    }
  ]...)
}

resource "azurerm_resource_group" "rg" {
  for_each = var.regions
  name     = "rg-${each.key}"
  location = each.value.location
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.regions
  name                = "vnet-${each.key}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.regions
  name                 = "subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create one network interface for each VM.
resource "azurerm_network_interface" "nic" {
  for_each = local.vm_instances

  name                = "nic-${each.key}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.value.region].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.region].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = local.vm_instances
  name                  = "vm-${each.key}"
  location              = each.value.location
  resource_group_name   = azurerm_resource_group.rg[each.value.region].name
  size                  = "Standard_B2ats_v2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  
    admin_ssh_key {
        username = "adminuser"
        public_key = var.ssh_public_key
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
}

