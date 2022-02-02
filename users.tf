# The Azure AD Terraform provider switches to the Microsoft Graph API as of version 2.0.0, 
# so when version 2 is released you will need to grant permissions to the Microsoft Graph API 
# instead of to the Azure Active Directory Graph API.
# When adding permissions to your Service Principal, you need to add Application permissions 
# rather than Delegated permissions. This means that the Service Principal is 
# allowed to perform the specified actions as itself, rather than on behalf of another user.
# We will create two users and two groups and assign each user to a group.

resource "azuread_user" "adamc" {
 user_principal_name   = "adamc@mydomain.com"
 display_name          = "Adam Connelly"
 password              = "SuperSecret01@!"
 force_password_change = true
}

resource "azuread_user" "bobd" {
 user_principal_name   = "bobd@mydomain.com"
 display_name          = "Bob Dolton"
 password              = "SuperSecret01@!"
 force_password_change = true
}

resource "azuread_group" "development" {
 display_name = "Development"
 members = [
   azuread_user.adamc.id
 ]
}

resource "azuread_group" "sales" {
 display_name = "Sales"
 members = [
   azuread_user.bobd.id
 ]
}