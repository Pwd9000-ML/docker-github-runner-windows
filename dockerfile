##### BASE IMAGE INFO ######
#Using servercore insider edition for compacted size.
#For compatibility on "your" host running docker you may need to use a specific tag.
#E.g. the host OS version must match the container OS version. 
#If you want to run a container based on a newer Windows build, make sure you have an equivalent host build. 
#Otherwise, you can use Hyper-V isolation to run older containers on new host builds. 
#The default entrypoint is for this image is Cmd.exe. To run the image:
#docker run mcr.microsoft.com/windows/servercore/insider:10.0.{build}.{revision}
#tag reference: https://mcr.microsoft.com/en-us/product/windows/servercore/insider/tags

#Win10
#FROM mcr.microsoft.com/windows/servercore/insider:10.0.19035.1

#Win11
FROM mcr.microsoft.com/windows/servercore/insider:10.0.20348.1

#input GitHub runner version argument
ARG RUNNER_VERSION

LABEL Author="Marcel L"
LABEL Email="pwd9000@hotmail.co.uk"
LABEL GitHub="https://github.com/Pwd9000-ML"
LABEL BaseImage="servercore/insider:10.0.20348.1"
LABEL RunnerVersion=${RUNNER_VERSION}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

#Set working directory
WORKDIR /actions-runner

#Install chocolatey
ADD scripts/Install-Choco.ps1 .
RUN .\Install-Choco.ps1 -Wait; \
    Remove-Item .\Install-Choco.ps1 -Force

#Install Git, GitHub-CLI, Azure-CLI and PowerShell Core with Chocolatey (add more tooling if needed at build)
RUN choco install -y \
    git \
    gh \
    powershell-core \
    azure-cli

#Download GitHub Runner based on RUNNER_VERSION argument (Can use: Docker build --build-arg RUNNER_VERSION=x.y.z)
RUN Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$env:RUNNER_VERSION/actions-runner-win-x64-$env:RUNNER_VERSION.zip" -OutFile "actions-runner.zip"; \
    Expand-Archive -Path ".\\actions-runner.zip" -DestinationPath '.'; \
    Remove-Item ".\\actions-runner.zip" -Force

#Add GitHub runner configuration startup script
ADD scripts/start.ps1 .
ADD scripts/Cleanup-Runners.ps1 .
ENTRYPOINT ["pwsh.exe", ".\\start.ps1"]