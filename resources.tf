# Here we define our resources and create Azure AD Groups, 
# some members and add group memberships to a subscription. 
# This will be used to create break-the-glass accounts, add it to a 
# group, then add the group to the subscription. 

resource "azuread_group" "aadgroup-btg" {
  display_name 	   = "aadbtg"
  security_enabled = "true"
}

data "azuread_group" "data-btg" {
  display_name     = "aaadbtg"
  security_enabled = true
  depends_on       = [azuread_group.aadgroup-btg]
}

# Create Service Principals for access 

resource "random_password" "password" {
  length           = 32
  min_upper        = 4
  min_numeric      = 4
  special          = true
  override_special = "_%@"
}

resource "azuread_user" "aaabtg01" {
  user_principal_name = "aaabtg01@internetofthings.com"
  display_name        = "Break The Glass"
  mail_nickname       = "aaabtg01"
  password            = "random_password.password.result"
}

data "azuread_user" "daabtg01" {
  user_principal_name = "aaabtg01@internetofthings.com"
  depends_on          = [azuread_user.aaabtg01]
}

resource "azuread_group_member" "example" {
  group_object_id  = azuread_group.aadgroup-btg.id
  member_object_id = data.azuread_user.daabtg01.id
}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributer"
  principal_id         = data.azuread_group.data-btg.object_id
  depends_on           = [data.azuread_group.data-btg]
}

data "azurerm_subscription" "primary" {
}

# The only thing missing now is the ability to define exclusion policies for the 
# conditional access rules for instance. We can also define monitoring rules for 
# the usage of these BTG accounts directly using Terraform as well to get alerted 
# if someone is trying to use the BTG accounts. This is referencing a Log Analytics 
# workspace with Sentinel to define the Analytics Query.

resource "azurerm_resource_group" "example-ra" {
  name     = "example-resources2"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-workspace"
  location            = azurerm_resource_group.example-ra.location
  resource_group_name = azurerm_resource_group.example-ra.name
  sku                 = "pergb2018"
}

resource "azurerm_log_analytics_solution" "la_sentinel" {
  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.example-ra.location
  resource_group_name   = azurerm_resource_group.example-ra.name
  workspace_resource_id = azurerm_log_analytics_workspace.example.id
  workspace_name        = azurerm_log_analytics_workspace.example.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}

resource "azurerm_sentinel_alert_rule_scheduled" "example3" {
  name                       = "example"
  log_analytics_workspace_id = azurerm_log_analytics_solution.la_sentinel.workspace_resource_id
  display_name               = "example"
  severity                   = "High"
  tactics                    = ["InitialAccess"]
  query                      = <<QUERY
SigninLogs
| where UserPrincipalName == "aaabtg01@evrypoc.com" 
| where Status.errorCode == 0
| extend AccountCustomEntity = Identity
| extend IPCustomEntity = IPAddress
| extend HostCustomEntity = SourceSystem
QUERY
}

