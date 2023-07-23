#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine@sha256:58e6de729b465daea5a30cc876c00523eb5e864ea086645d726040d73750247e AS base
WORKDIR /app
RUN apk update && apk upgrade -a
EXPOSE 80
EXPOSE 443

### BUILD ###
FROM mcr.microsoft.com/dotnet/sdk:7.0-alpine@sha256:b4b1f1b7d85a7b9939004e6632009d8c3857d3a931378eebced7e2018780b84e AS build
WORKDIR /src

ARG BUILD_VERSION
ARG ARCHIVE_URL=https://github.com/microsoft/CloudAdoptionFramework/archive/
ARG GIT_URL=https://github.com/jauderho/CloudAdoptionFramework.git

RUN test -n "${BUILD_VERSION}" \
	&& apk update \
	&& apk upgrade -a \
	&& apk add --no-cache bash git \
	&& git clone --depth 1 ${GIT_URL} /src \
	&& cd /src/ready/AzNamingTool \
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

