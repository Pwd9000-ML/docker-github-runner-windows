# docker-github-runner-windows

Repository for building a self hosted GitHub runner as a windows container.

More documentation to come...

## notes

### commands - Docker

```txt
docker build --build-arg RUNNER_VERSION=2.292.0 --tag gh-runner-image .
docker inspect gh-runner-image
docker run -e GH_TOKEN='myPatToken' -e GH_OWNER='orgName' -e GH_REPOSITORY='repoName' -d gh-runner-image
```

### commands - Compose

```powershell
docker-compose build
#set system environment with $env: (or .env file to pass GH_TOKEN)
$env:GH_TOKEN=myPatToken
docker-compose up --scale runner=3 -d
docker-compose up --scale runner=1 -d
docker-compose stop
```

### Clanup - powershell
.\scripts\Cleanup-Runners.ps1 -owner "Pwd9000-ML" -repo "docker-github-runner-windows" -pat "patToken"