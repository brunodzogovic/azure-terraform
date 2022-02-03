# Azure cloud backend managed by terraform

The IaaC deploys Azure user and adds it to a group as defined in the "resources.tf" file, then adds a random password and a role. The user is an identity for a IoT device that belongs to an identity federation management system (IdP). Last but not least, the code provisions the Azure Sentinel log analytics for collecting data from the authenticated devices and prepare it for machine learning (third party python scripts are dedicated for this purpose and not part of this repository).

A Powershell script creates a Service Principal for the cloud user that owns/manages a provisioned application in the Active Directory. Terraform queries the Microsoft Graph API to associate the provisioned user(s) of the IoT devices to the designated Service Principal. To create the SP in a simpler way, one can run the following (provided that azure cli access is enabled to the cloud): 

```
subscriptionId="$(az account list --query [].id -o tsv)"
$sp = az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$subscriptionId" -n TerraformTesting | ConvertFrom-Json
```

The second script sets up permissions for the Service Principal, which can be adjusted also based on user input
