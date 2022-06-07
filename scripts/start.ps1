#This script invokes GitHub-CLI (Already installed on container image)
#To use this entrypoint script run: Docker run -e GH_TOKEN='myPatToken' -e GH_OWNER='orgName' -e GH_REPOSITORY='repoName' -d imageName 
Param (
    [Parameter(Mandatory = $false)]
    [string]$owner = $env:GH_OWNER,
    [Parameter(Mandatory = $false)]
    [string]$repo = $env:GH_REPOSITORY,
    [Parameter(Mandatory = $false)]
    [string]$pat = $env:GH_TOKEN
)

#Use --with-token to pass in a PAT token on standard input. The minimum required scopes for the token are: "repo", "read:org".
#Alternatively, gh will use the authentication token found in environment variables. See gh help environment for more info.
#To use gh in GitHub Actions, add GH_TOKEN: $ to "env". on Docker run: Docker run -e GH_TOKEN='myPatToken'
gh auth login

#Get Runner registration Token
$jsonObj = gh api --method POST -H "Accept: application/vnd.github.v3+json" "/repos/$owner/$repo/actions/runners/registration-token"
$regToken = (ConvertFrom-Json -InputObject $jsonObj).token
$runnerBaseName = "dockerNode-"
$runnerName = $runnerBaseName + (((New-Guid).Guid).replace("-", "")).substring(0, 5)

try {
    #Register new runner instance
    write-host "Registering GitHub Self Hosted Runner on: $owner/$repo"
    ./config.cmd --unattended --url "https://github.com/$owner/$repo" --token $regToken --name $runnerName

    #Remove PAT token after registering new instance
    $pat=$null
    $env:GH_TOKEN=$null

    #Start runner listener for jobs
    ./run.cmd
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    # Trap signal with finally - cleanup (When docker container is stopped remove runner registration from GitHub)
    # Does not currently work due to issue: https://github.com/moby/moby/issues/25982#
    # Perform manual cleanup of stale runners using Cleanup-Runners.ps1
    ./config.cmd remove --unattended --token $regToken
}