#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine@sha256:d53ea7c514d62ad74fd4ca9065776a94063393f5993a4e6c0b219b7abed91b78 AS base
WORKDIR /app
RUN apk update && apk upgrade -a
EXPOSE 80
EXPOSE 443

### BUILD ###
FROM mcr.microsoft.com/dotnet/sdk:7.0-alpine@sha256:ba04d2d249d045c4324f8f238f0b82a08528a61db969ba9b0c549b8bc1dc9127 AS build
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

