#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
#FROM mcr.microsoft.com/dotnet/aspnet:6.0@sha256:03555d92065f11067c9e2f259787fa858a03313540a01f10cde6bfd720671285 AS base
#FROM mcr.microsoft.com/dotnet/aspnet:7.0@sha256:debec27f5579ddee99c2fd5616ee18def873aa83ad68e7b563c222162099fda5 AS base
FROM mcr.microsoft.com/dotnet/aspnet:7.0-alpine@sha256:1116d7a1b7d16089a8890d080a64ed58beff822f02443d865a5bef43c947ffea AS base
WORKDIR /app
RUN apk update && apk upgrade -a
EXPOSE 80
EXPOSE 443

### BUILD ###
#FROM mcr.microsoft.com/dotnet/sdk:6.0@sha256:408f1593d25f04e5d1c97115da40760ca032505c97dafd7d5a291e0a3ae88c61 AS build
#FROM mcr.microsoft.com/dotnet/sdk:7.0@sha256:028d360c0f409f13daf8689edfe680dba9d4b651eb8a6f1210a3542f0ad4bf58 AS build
FROM mcr.microsoft.com/dotnet/sdk:7.0-alpine@sha256:626f01d39214df0611f7e4a29083447dbeb80b5f42e6182581cf891bee2cf712 AS build
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

