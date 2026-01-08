provider "azurerm" {
features {}
subscription_id = "0dbc7906-293b-41aa-916d-9f62c7c48126"
}


locals {
  location = "centralindia"
}




resource "azurerm_resource_group" "testrg" {
name = "yuvirg"
location = local.location
}

resource "azurerm_resource_group" "testrg1" {
  name = "harshitrg"
  location = local.location

#   lifecycle {
#     create_before_destroy = true
#   }
}

# import {
#   to = azurerm_resource_group.testrg1
#   id = "/subscriptions/0dbc7906-293b-41aa-916d-9f62c7c48126/resourceGroups/harshitrg"
# }

resource "azurerm_virtual_network" "testvirtualnetwork"{

name = "yuvivnet"
location = azurerm_resource_group.testrg.location
resource_group_name = azurerm_resource_group.testrg.name
address_space = ["10.0.0.0/16"] 

}

resource "azurerm_subnet" "testsubnet" {

name = "yuvisubnet"
resource_group_name = azurerm_resource_group.testrg.name
virtual_network_name =azurerm_virtual_network.testvirtualnetwork.name
address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "testpip" {
  name                = "yuvipip"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "testnic" {

name = "yuvinic"
location = azurerm_resource_group.testrg.location
resource_group_name = azurerm_resource_group.testrg.name

ip_configuration  {

name = "internal"
private_ip_address_allocation = "Dynamic"
subnet_id = azurerm_subnet.testsubnet.id
public_ip_address_id = azurerm_public_ip.testpip.id
}
}

variable "passwordv" {
    type = string 
    sensitive = true 
    
  
}
resource "azurerm_linux_virtual_machine" "testlvm" {

name = "yuvivm"
location = azurerm_resource_group.testrg.location
resource_group_name =azurerm_resource_group.testrg.name
size = "Standard_B4as_v2"
network_interface_ids = [azurerm_network_interface.testnic.id]
admin_username ="adminuser"
admin_password = var.passwordv
disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }


}