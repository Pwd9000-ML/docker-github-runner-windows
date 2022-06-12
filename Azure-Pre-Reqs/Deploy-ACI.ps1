#az login

#Variables
$randomInt = Get-Random -Maximum 9999
$aciResourceGroupName = "Demo-ACI-GitHub-Runners-RG" #Resource group created to deploy ACIs
$aciName = "gh-runner-windows-$randomInt" #ACI name (unique)
$acrLoginServer = "registryName.azurecr.io" #The login server name of the ACR (all lowercase). Example: _myregistry.azurecr.io_
$acrUsername = "servicePrincipalClientId" #The `clientId` from the JSON output from the service principal creation (See part 3 of blog series)
$acrPassword = "servicePrincipalClientSecret" #The `clientSecret` from the JSON output from the service principal creation (See part 3 of blog series)
$image = "$acrLoginServer/pwd9000-github-runner-win:2.293.0" #image reference to pull
$pat = "githubPAT" #GitHub PAT token
$githubOrg = "Pwd9000-ML" #GitHub Owner
$githubRepo = "docker-github-runner-windows" #GitHub repository to register self hosted runner against
$osType = "Windows" #Use "Linux" if image is Linux OS

az container create --resource-group "$aciResourceGroupName" `
    --name "$aciName" `
    --image "$image" `
    --registry-login-server "$acrLoginServer" `
    --registry-username "$acrUsername" `
    --registry-password "$acrPassword" `
    --environment-variables GH_TOKEN="$pat" GH_OWNER="$githubOrg" GH_REPOSITORY="$githubRepo" `
    --os-type "$osType"#Log into Azure
#az login

# Setup Variables.
$aciResourceGroupName = "Demo-ACI-GitHub-Runners-RG"
$appName = "GitHub-ACI-Deploy" #Previously created Service Principal (See part 3 of blog series)
#$acrName="<ACRName>"
$region = "uksouth"

# Create a resource group to deploy ACIs to
az group create --name "$aciResourceGroupName" --location "$region"
$aciRGId = az group show --name "$aciResourceGroupName" --query id --output tsv

# Create AAD App and Service Principal and assign to RBAC Role to ACI deployment RG
az ad sp list --display-name $appName --query [].appId -o tsv | ForEach-Object {
    az role assignment create --assignee "$_" `
        --role "Contributor" `
        --scope "$aciRGId"
}
