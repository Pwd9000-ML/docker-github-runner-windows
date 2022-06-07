#This script invokes GitHub-CLI (Pre-installed on container image)
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
gh auth login --with-token $pat

#Cleanup#
#Look for any old/stale dockerNode- registrations to clean up
#Windows containers cannot gracefully remove registration via powershell due to issue: https://github.com/moby/moby/issues/25982#
#For this reason we can use this scrip to cleanup old offline instances/registrations
$runnerBaseName = "dockerNode-"
$runnerListJson = gh api -H "Accept: application/vnd.github.v3+json" "/repos/$owner/$repo/actions/runners"
$runnerList = (ConvertFrom-Json -InputObject $runnerListJson).runners

Foreach ($runner in $runnerList) {
    try {
        If (($runner.name -like "$runnerBaseName*") -and ($runner.status -eq "offline")) {
            write-host "Unregsitering old stale runner: $($runner.name)"
            gh api --method DELETE -H "Accept: application/vnd.github.v3+json" "/repos/$owner/$repo/actions/runners/$($runner.id)"
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

#Remove PAT token after cleanup
$pat=$null
$env:GH_TOKEN=$null