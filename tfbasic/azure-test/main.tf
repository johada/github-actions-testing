provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "frontdoor-test-rg"
  location = "eastus2"
}

module "frontdoor_wafpolicy" {
  source              = "git::git@github.com:Rockwell-Automation-Inc/terraform-azurerm-cdn-frontdoor-firewall-policy-module.git?ref=v0.0.2"
  tags                = local.tags
  name                = "TestingExclusionFrontDoorWAFPolicy"
  resource_group_name = azurerm_resource_group.example.name
  # managed_rules = [{
  #   type    = "Microsoft_DefaultRuleSet"
  #   version = "2.1"
  #   action  = "Block"
  #   overrides = [{
  #     rule_group_name = "SQLI"
  #     rules = [{
  #       action  = "Log"
  #       enabled = true
  #       rule_id = "942120"
  #       exclusions = [{
  #         match_variable = "QueryStringArgNames"
  #         operator       = "Contains"
  #         selector       = "search"
  #       }]
  #     }]
  #   }]
  #   overrides = [{
  #     rule_group_name = "MS-ThreatIntel-SQLI"
  #     rules = [{
  #       action  = "Log"
  #       enabled = true
  #       rule_id = "99031001"
  #       exclusions = [{
  #         match_variable = "QueryStringArgNames"
  #         operator       = "Contains"
  #         selector       = "search"
  #       }]
  #     }]
  #   }]
  # }]
}


