# data "azurerm_resource_group" "main" {
#   name = var.resource_group_name
# }

locals {
  authorization_rules = [
    for rule in var.authorization_rules : merge({
      name   = ""
      rights = []
    }, rule)
  ]

  default_authorization_rule = {
    name                        = "RootManageSharedAccessKey"
    primary_connection_string   = azurerm_servicebus_namespace.main.default_primary_connection_string
    secondary_connection_string = azurerm_servicebus_namespace.main.default_secondary_connection_string
    primary_key                 = azurerm_servicebus_namespace.main.default_primary_key
    secondary_key               = azurerm_servicebus_namespace.main.default_secondary_key
  }

  topics = [
    for topic in var.topics : merge({
      name                       = ""
      status                     = "Active"
      auto_delete_on_idle        = null
      default_message_ttl        = null
      enable_batched_operations  = null
      enable_express             = null
      enable_partitioning        = null
      max_size                   = null
      enable_duplicate_detection = null
      enable_ordering            = null
      authorization_rules        = []
      subscriptions              = []

      duplicate_detection_history_time_window = null
    }, topic)
  ]

  topic_authorization_rules = flatten([
    for topic in local.topics : [
      for rule in topic.authorization_rules : merge({
        name   = ""
        rights = []
        }, rule, {
        topic_name = topic.name
      })
    ]
  ])

  topic_subscriptions = flatten([
    for topic in local.topics : [
      for subscription in topic.subscriptions :
      merge({
        name                      = ""
        auto_delete_on_idle       = null
        default_message_ttl       = null
        lock_duration             = null
        enable_batched_operations = null
        max_delivery_count        = null
        enable_session            = null
        forward_to                = null
        rules                     = []

        enable_dead_lettering_on_message_expiration = null
        }, subscription, {
        topic_name = topic.name
      })
    ]
  ])

  topic_subscription_rules = flatten([
    for subscription in local.topic_subscriptions : [
      for rule in subscription.rules : merge({
        name       = ""
        sql_filter = ""
        action     = ""
        }, rule, {
        topic_name        = subscription.topic_name
        subscription_name = subscription.name
      })
    ]
  ])

  queues = [
    for queue in var.queues : merge({
      name                       = ""
      auto_delete_on_idle        = null
      default_message_ttl        = null
      enable_express             = false
      enable_partitioning        = false
      lock_duration              = null
      max_size                   = null
      enable_duplicate_detection = false
      enable_session             = false
      max_delivery_count         = 10
      authorization_rules        = []

      enable_dead_lettering_on_message_expiration = false
      duplicate_detection_history_time_window     = null
    }, queue)
  ]

  queue_authorization_rules = flatten([
    for queue in local.queues : [
      for rule in queue.authorization_rules : merge({
        name   = ""
        rights = []
        }, rule, {
        queue_name = queue.name
      })
    ]
  ])
}

module "labels" {
  source      = "git::git@github.com:slovink/terraform-azure-labels.git"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

resource "azurerm_servicebus_namespace" "main" {
  name                = format("%s-service-bus", module.labels.id)
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
  tags                = module.labels.tags
}

resource "azurerm_servicebus_namespace_authorization_rule" "main" {
  count = length(local.authorization_rules)

  name         = local.authorization_rules[count.index].name
  namespace_id = azurerm_servicebus_namespace.main.id

  listen = contains(local.authorization_rules[count.index].rights, "listen") ? true : false
  send   = contains(local.authorization_rules[count.index].rights, "send") ? true : false
  manage = contains(local.authorization_rules[count.index].rights, "manage") ? true : false
}

resource "azurerm_servicebus_topic" "main" {
  count = length(local.topics)

  name         = local.topics[count.index].name
  namespace_id = azurerm_servicebus_namespace.main.id

  status                       = local.topics[count.index].status
  auto_delete_on_idle          = local.topics[count.index].auto_delete_on_idle
  default_message_ttl          = local.topics[count.index].default_message_ttl
  enable_batched_operations    = local.topics[count.index].enable_batched_operations
  enable_express               = local.topics[count.index].enable_express
  enable_partitioning          = local.topics[count.index].enable_partitioning
  max_size_in_megabytes        = local.topics[count.index].max_size
  requires_duplicate_detection = local.topics[count.index].enable_duplicate_detection
  support_ordering             = local.topics[count.index].enable_ordering

  duplicate_detection_history_time_window = local.topics[count.index].duplicate_detection_history_time_window
}

resource "azurerm_servicebus_topic_authorization_rule" "main" {
  count = length(local.topic_authorization_rules)

  name     = local.topic_authorization_rules[count.index].name
  topic_id = azurerm_servicebus_topic.main.*.id[count.index]

  listen = contains(local.topic_authorization_rules[count.index].rights, "listen") ? true : false
  send   = contains(local.topic_authorization_rules[count.index].rights, "send") ? true : false
  manage = contains(local.topic_authorization_rules[count.index].rights, "manage") ? true : false

  depends_on = [azurerm_servicebus_topic.main]
}

resource "azurerm_servicebus_subscription" "main" {
  count = length(local.topic_subscriptions)

  name     = local.topic_subscriptions[count.index].name
  topic_id = azurerm_servicebus_topic.main.*.id[count.index]

  max_delivery_count        = local.topic_subscriptions[count.index].max_delivery_count
  auto_delete_on_idle       = local.topic_subscriptions[count.index].auto_delete_on_idle
  default_message_ttl       = local.topic_subscriptions[count.index].default_message_ttl
  lock_duration             = local.topic_subscriptions[count.index].lock_duration
  enable_batched_operations = local.topic_subscriptions[count.index].enable_batched_operations
  requires_session          = local.topic_subscriptions[count.index].enable_session
  forward_to                = local.topic_subscriptions[count.index].forward_to

  dead_lettering_on_message_expiration = local.topic_subscriptions[count.index].enable_dead_lettering_on_message_expiration

  depends_on = [azurerm_servicebus_topic.main]
}

resource "azurerm_servicebus_subscription_rule" "main" {
  count = length(local.topic_subscription_rules)

  name = local.topic_subscription_rules[count.index].name

  subscription_id = azurerm_servicebus_subscription.main.*.id[count.index]
  filter_type     = local.topic_subscription_rules[count.index].sql_filter != "" ? "SqlFilter" : null
  sql_filter      = local.topic_subscription_rules[count.index].sql_filter
  action          = local.topic_subscription_rules[count.index].action

  depends_on = [azurerm_servicebus_subscription.main]
}

resource "azurerm_servicebus_queue" "main" {
  count = length(local.queues)

  name         = local.queues[count.index].name
  namespace_id = azurerm_servicebus_namespace.main.id

  auto_delete_on_idle                  = local.queues[count.index].auto_delete_on_idle
  default_message_ttl                  = local.queues[count.index].default_message_ttl
  enable_express                       = local.queues[count.index].enable_express
  enable_partitioning                  = local.queues[count.index].enable_partitioning
  lock_duration                        = local.queues[count.index].lock_duration
  max_size_in_megabytes                = local.queues[count.index].max_size
  requires_duplicate_detection         = local.queues[count.index].enable_duplicate_detection
  requires_session                     = local.queues[count.index].enable_session
  dead_lettering_on_message_expiration = local.queues[count.index].enable_dead_lettering_on_message_expiration
  max_delivery_count                   = local.queues[count.index].max_delivery_count

  duplicate_detection_history_time_window = local.queues[count.index].duplicate_detection_history_time_window
}

resource "azurerm_servicebus_queue_authorization_rule" "main" {
  count = length(local.queue_authorization_rules)

  name     = local.queue_authorization_rules[count.index].name
  queue_id = azurerm_servicebus_queue.main.*.id[count.index]

  listen = contains(local.queue_authorization_rules[count.index].rights, "listen") ? true : false
  send   = contains(local.queue_authorization_rules[count.index].rights, "send") ? true : false
  manage = contains(local.queue_authorization_rules[count.index].rights, "manage") ? true : false

  depends_on = [azurerm_servicebus_queue.main]
}
