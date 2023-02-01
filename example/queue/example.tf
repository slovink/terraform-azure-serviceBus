provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "git::git@github.com:slovink/terraform-azure-resource-group.git"

  label_order = ["name", "environment"]
  name        = "rg"
  environment = "examplee"
  location    = "Canada Central"
}

module "service_bus" {
  source = "./../../"

  name        = "example-huro-test"
  environment = "test"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  sku                 = "Standard"

  queues = [
    {
      name = "example"
      authorization_rules = [
        {
          name   = "example"
          rights = ["listen", "send"]
        }
      ]
    }
  ]
}
