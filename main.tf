
#resource "azurerm_resource_group" "test1" {
#  name     = "stovl1"
#  location = "South India"
#}

resource "azurerm_storage_account" "test1" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.storage_account_location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}

resource "azurerm_service_plan" "test1" {
  name                = "test1-service-plan"
  location            = "East US"
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_function_app" "test1" {
  name                = "KF-function-app"
  location            = "East US"
  resource_group_name = "stovl1"
  service_plan_id     = azurerm_service_plan.test1.id

  storage_account_name       = azurerm_storage_account.test1.name
  storage_account_access_key = azurerm_storage_account.test1.primary_access_key

  site_config {
    application_stack {
      dotnet_version = "6"
    }
  }
}


resource "azurerm_function_app_function" "test1" {
  name            = "KFHTTP-function-app-function"
  function_app_id = azurerm_windows_function_app.test1.id
  language        = "CSharp"

  file {
    name    = "run.csx"
    content = file("run.csx")
  }

  test_data = jsonencode({
    "name" = "Azure"
  })

  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}
