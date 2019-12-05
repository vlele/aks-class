FROM microsoft/aspnetcore:2.0 AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/aspnetcore-build:2.0 AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./bin/*.csproj ./
RUN dotnet restore

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY ./bin/. ./
ENTRYPOINT ["dotnet", "aisazdevops-taskapi.dll"]