resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_communication_service" "this" {
  name                = "${var.stage}-acs-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = local.tags
}

# Create the Email Communication Service
resource "azurerm_email_communication_service" "this" {
  name                = "${var.stage}-acs-em-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = local.tags
}

resource "azurerm_email_communication_service_domain" "this" {
  name              = var.custom_domain != null ? var.custom_domain.domain_name : "AzureManagedDomain"
  email_service_id  = azurerm_email_communication_service.this.id
  domain_management = var.custom_domain != null ? "CustomerManaged" : "AzureManaged"
  tags              = local.tags
}

# Domain Verification: TXT Records
resource "azurerm_dns_txt_record" "domain" {
  provider            = azurerm.dns
  count               = var.custom_domain != null ? 1 : 0
  name                = "@"
  zone_name           = var.custom_domain.domain_name
  resource_group_name = var.custom_domain.resource_group_name
  ttl                 = azurerm_email_communication_service_domain.this.verification_records[0].domain[0].ttl

  # Domain Verification
  record {
    value = azurerm_email_communication_service_domain.this.verification_records[0].domain[0].value
  }

  # SPF Verification
  record {
    value = azurerm_email_communication_service_domain.this.verification_records[0].spf[0].value
  }
  depends_on = [azurerm_email_communication_service_domain.this]
  tags       = local.tags
}

# CNAME DKIM and DKIM2 Records
resource "azurerm_dns_cname_record" "dkim_records" {
  provider            = azurerm.dns
  for_each            = { for cname in ["dkim", "dkim2"] : cname => cname if var.custom_domain != null }
  name                = azurerm_email_communication_service_domain.this.verification_records[0][each.key][0].name
  zone_name           = var.custom_domain.domain_name
  resource_group_name = var.custom_domain.resource_group_name
  record              = azurerm_email_communication_service_domain.this.verification_records[0][each.key][0].value
  ttl                 = azurerm_email_communication_service_domain.this.verification_records[0][each.key][0].ttl
  depends_on          = [azurerm_email_communication_service_domain.this]

  tags = local.tags
}

# Initiate: Domain Verification 
resource "azapi_resource_action" "initiate_validation_domain" {
  for_each    = { for verify in ["Domain"] : verify => verify if var.custom_domain != null }
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.this.id

  body = {
    verificationType = each.key
  }
  depends_on = [
    azurerm_dns_txt_record.domain,
  ]
}

# Initiate: SPF Verification 
resource "azapi_resource_action" "initiate_validation_spf" {
  for_each    = { for verify in ["SPF"] : verify => verify if var.custom_domain != null }
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.this.id

  body = {
    verificationType = each.key
  }
  depends_on = [
    azurerm_dns_txt_record.domain,
    azapi_resource_action.initiate_validation_domain,
  ]
}

resource "azapi_resource_action" "initiate_validation_dkim" {
  for_each    = { for verify in ["DKIM"] : verify => verify if var.custom_domain != null }
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.this.id

  body = {
    verificationType = each.key
  }
  depends_on = [
    azurerm_dns_txt_record.domain,
    azapi_resource_action.initiate_validation_spf,
  ]
}

resource "azapi_resource_action" "initiate_validation_dkim2" {
  for_each    = { for verify in ["DKIM2"] : verify => verify if var.custom_domain != null }
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  action      = "initiateVerification"
  resource_id = azurerm_email_communication_service_domain.this.id

  body = {
    verificationType = each.key
  }
  depends_on = [
    azurerm_dns_txt_record.domain,
    azapi_resource_action.initiate_validation_dkim,
  ]
}

resource "time_sleep" "wait_for_validation_success" {
  depends_on      = [azapi_resource_action.initiate_validation_dkim2]
  create_duration = "30s"
}

resource "azapi_resource_action" "associate_validated_domain" {
  count       = var.custom_domain != null ? 1 : 0
  type        = "Microsoft.Communication/CommunicationServices@2023-03-31"
  method      = "PATCH"
  resource_id = azurerm_communication_service.this.id

  body = {
    properties = {
      linkedDomains = [azurerm_email_communication_service_domain.this.id]
    }
  }
  depends_on = [time_sleep.wait_for_validation_success]
}

resource "azapi_resource_action" "unlink_validated_domain" {
  count       = var.custom_domain != null ? 1 : 0
  when        = "destroy"
  type        = "Microsoft.Communication/CommunicationServices@2023-03-31"
  method      = "PATCH"
  resource_id = azurerm_communication_service.this.id
  body = {
    properties = {
      linkedDomains = []
    }
  }
  depends_on = [
    azapi_resource_action.initiate_validation_domain,
    azapi_resource_action.initiate_validation_spf,
    azapi_resource_action.initiate_validation_dkim,
    azapi_resource_action.initiate_validation_dkim2,
  ]
}

resource "azapi_resource" "sender_username" {
  for_each  = toset(try(var.custom_domain.sender_usernames, []))
  type      = "Microsoft.Communication/emailServices/domains/senderUsernames@2023-04-01-preview"
  name      = each.key
  parent_id = azurerm_email_communication_service_domain.this.id
  body = {
    properties = {
      displayName = each.key
      username    = each.key
    }
  }
}
