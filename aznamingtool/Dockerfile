#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
#FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine3.22@sha256:14f13652a7907d905063a9103731c9244e42cbd2f6c588a2d9666677bab0370b AS base
#WORKDIR /app
#RUN apk update && apk upgrade -a
#EXPOSE 80
#EXPOSE 443

### BUILD ###
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine3.22@sha256:bdd1c9e2215a71e43d2f0c6978ace0a0652d7ecc21bf6f659d42d840500e1c44 AS build
WORKDIR /src

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/mspnp/AzureNamingTool/archive/
ARG GIT_URL=https://github.com/jauderho/AzureNamingTool.git
#ARG ARCHIVE_URL=https://github.com/microsoft/CloudAdoptionFramework/archive/
#ARG GIT_URL=https://github.com/jauderho/CloudAdoptionFramework.git

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
#FROM base AS final
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine3.22@sha256:14f13652a7907d905063a9103731c9244e42cbd2f6c588a2d9666677bab0370b
WORKDIR /app

LABEL org.opencontainers.image.authors="Jauder Ho <jauderho@users.noreply.github.com>"
LABEL org.opencontainers.image.url="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.documentation="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.source="https://github.com/jauderho/dockerfiles"
LABEL org.opencontainers.image.title="jauderho/aznamingtool"
LABEL org.opencontainers.image.description="AzNamingTool assists with the configuration and generation of Azure Resource names"

RUN apk update && apk upgrade -a

EXPOSE 80
EXPOSE 443

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "AzureNamingTool.dll"]

