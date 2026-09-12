terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "satyajeettfstate2026"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"

    use_azuread_auth = true
    use_cli          = true
  }
}