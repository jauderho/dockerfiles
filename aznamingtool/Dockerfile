#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
#FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine3.22@sha256:14f13652a7907d905063a9103731c9244e42cbd2f6c588a2d9666677bab0370b AS base
#WORKDIR /app
#RUN apk update && apk upgrade -a
#EXPOSE 80
#EXPOSE 443

### BUILD ###
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine3.24@sha256:620e765fe18186c08399f7aa978f79f04b6bbf0ee1b3b8a91e2d5c9619e59da1 AS build
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
	# Framework-dependent publish. The final stage below is the aspnet runtime
	# image, so it already carries the shared framework; a self-contained build
	# bundled a second copy of it into the app (~164MB of pure duplication).
	# --self-contained also implied PublishSingleFile, which emits a native
	# AzureNamingTool executable and no AzureNamingTool.dll - the ENTRYPOINT
	# below could not start it. PublishTrimmed goes with it, as trimming is
	# only supported for self-contained output. PublishReadyToRun stays: it
	# pre-compiles to native code, so startup is not traded away for the size.
	&& dotnet restore "AzureNamingTool.csproj" -r linux-musl-x64 /p:SelfContained=false /p:PublishReadyToRun=true \
	&& dotnet build "AzureNamingTool.csproj" -r linux-musl-x64 -c Release -o /app/build --self-contained false --no-restore /p:PublishReadyToRun=true \
	&& dotnet publish "AzureNamingTool.csproj" -r linux-musl-x64 -c Release -o /app/publish --self-contained false --no-restore /p:PublishReadyToRun=true \
	&& apk del bash git \
	&& rm -rf /var/cache/apk/*

### FINAL ###
#FROM base AS final
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine3.24@sha256:c4b29bf368004ad9076c1ab9bc91fb373561e3905b4345637e14e8b8c57e3be8
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

