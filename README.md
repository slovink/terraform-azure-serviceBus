
<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform Azure serviceBus
</h1>

<p align="center" style="font-size: 1.2rem;">
    Terraform module to create serviceBus resource on Azure.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v1.7.4-green" alt="Terraform">
</a>
<a href="https://github.com/slovink/terraform-azure-servicebus/blob/dev/LICENSE">
  <img src="https://img.shields.io/badge/License-APACHE-blue.svg" alt="Licence">
</a>






## Prerequisites

This module has a few dependencies:

- [Terraform 1.x.x](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/slovink/terraform-azure-serviceBus/releases).


### Basic
Here is an example of how you can use this module in your inventory structure:
  ```hcl
## basic
module "service_bus" {
  source              = "https://github.com/slovink/terraform-azure-serviceBus.git?ref=1.0.0"
  name                = "example-huro"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  sku                 = "Basic"
}
```

##### queue
Here is an example of how you can use this module in your inventory structure:
  ```hcl

module "service_bus" {
  source              = "https://github.com/slovink/terraform-azure-serviceBus.git?ref=1.0.0"
  name                = "example-huro-test"
  environment         = "test"
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
```
#### topic
Here is an example of how you can use this module in your inventory structure:
  ```hcl
module "service_bus" {
  source               = "https://github.com/slovink/terraform-azure-serviceBus.git?ref=1.0.0"
  name                 = "example-huro-test"
  environment          = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  sku                 = "Standard"

  topics = [
    {
      name                = "example"
      enable_partitioning = true
      authorization_rules = [
        {
          name   = "example"
          rights = ["listen", "send"]
        }
      ]
    }
  ]
}
```
##### topic_with_subscriptions
Here is an example of how you can use this module in your inventory structure:
  ```hcl
module "service_bus" {
  source              = "https://github.com/slovink/terraform-azure-serviceBus.git?ref=1.0.0"
  name                = "example-huro-test"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  sku                 = "Standard"

  topics = [
    {
      name                = "source"
      enable_partitioning = true
      subscriptions = [
        {
          name               = "example"
          forward_to         = "destination"
          max_delivery_count = 1
        }
      ]
    },
    {
      name                = "destination"
      enable_partitioning = true
    }
  ]
}
```

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/slovink/terraform-azure-serviceBus/blob/dev/LICENSE) file for details.


## Examples
For detailed examples on how to use this module, please refer to the [Examples](https://github.com/slovink/terraform-azure-serviceBus/tree/dev/example) directory within this repository.



## Feedback
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/slovink/terraform-azure-serviceBus/issues), or feel free to drop us an email at [devops@slovink.com](mailto:devops@slovink.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/slovink/terraform-azure-serviceBus)!

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.7.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.87.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.87.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | git::git@github.com:slovink/terraform-azure-labels.git | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_servicebus_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_queue.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_subscription.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) | resource |
| [azurerm_servicebus_subscription_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription_rule) | resource |
| [azurerm_servicebus_topic.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |
| [azurerm_servicebus_topic_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | List of namespace authorization rules. | `any` | `[]` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | The number of message units. | `number` | `0` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] . | `list(any)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The name of an existing resource group. | `string` | n/a | yes |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'slovink'. | `string` | `"contact@slovink.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | List of queues. | `any` | `[]` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of an existing resource group. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the namespace. The options are: `Basic`, `Standard`, `Premium`. | `string` | `"Basic"` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | List of topics. | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The namespace ID. |
| <a name="output_name"></a> [name](#output\_name) | The namespace name. |
<!-- END_TF_DOCS -->
