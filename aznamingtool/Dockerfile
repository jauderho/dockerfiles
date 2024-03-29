#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine@sha256:646b1c5ff36375f35f6149b0ce19ca095f97b4b882b90652801e9fbe82bcfa8a AS base
#FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine@sha256:cd19e7b158aec55bf2eaa468b44794b05f11a932514fe093ca23bea660822acd AS base
WORKDIR /app
RUN apk update && apk upgrade -a
EXPOSE 80
EXPOSE 443

### BUILD ###
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine@sha256:b141e243684bd341229c0f9cddf185adffda918f423398fbc67a84fd676fd3d8 AS build
#FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine@sha256:fcf11110dd72ac7d83edc1d0103024a055476eb8c78add62557317f0f9c42eb6 AS build
WORKDIR /src

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/mspnp/AzureNamingTool/archive/
#ARG ARCHIVE_URL=https://github.com/microsoft/CloudAdoptionFramework/archive/
#ARG GIT_URL=https://github.com/jauderho/CloudAdoptionFramework.git
ARG GIT_URL=https://github.com/jauderho/AzureNamingTool.git

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bash git \
	&& git clone --depth 1 ${GIT_URL} /src \
	&& cd /src/src \
	&& dotnet restore "AzureNamingTool.csproj" -r linux-musl-x64 /p:PublishReadyToRun=true \
	&& dotnet build "AzureNamingTool.csproj" -r linux-musl-x64 -c Release -o /app/build --self-contained true --no-restore /p:PublishTrimmed=true /p:PublishReadyToRun=true /p:PublishSingleFile=true \
	&& dotnet publish "AzureNamingTool.csproj" -r linux-musl-x64 -c Release -o /app/publish --self-contained true --no-restore /p:PublishTrimmed=true /p:PublishReadyToRun=true /p:PublishSingleFile=true \
	&& apk del bash git \
	&& rm -rf /var/cache/apk/*

### FINAL ###
FROM base AS final
WORKDIR /app

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/aznamingtool"
LABEL org.opencontainers.image.description="AzNamingTool assists with the configuration and generation of Azure Resource names"

RUN apk update && apk upgrade -a

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "AzureNamingTool.dll"]

