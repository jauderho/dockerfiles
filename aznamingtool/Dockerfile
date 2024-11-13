#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

### BASE ###
#FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine3.20@sha256:1d9e1eb36eb822e7be487e7a11cd2350529e14e5e91484a08b501c9822867be4 AS base
#WORKDIR /app
#RUN apk update && apk upgrade -a
#EXPOSE 80
#EXPOSE 443

### BUILD ###
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine3.20@sha256:e79cc91f941191e83b0f124fe6502b4e1b11a4e5f1d4695b398f53c8e275b3ad AS build
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
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine3.20@sha256:4c3901bfc7d61d3e20e68f2034688dc83ac0c79d6c2b0e28eddd4b4ac0b9f5f4
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

