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

```txt
docker-compose build
GH_TOKEN=myPatToken docker-compose up --scale runner=3 -d
GH_TOKEN=myPatToken docker-compose up --scale runner=1 -d
docker-compose stop
```