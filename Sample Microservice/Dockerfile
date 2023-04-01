#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Sample Web Api/Sample Web Api.csproj", "Sample Web Api/"]
RUN dotnet restore "Sample Web Api/Sample Web Api.csproj"
COPY . .
WORKDIR "/src/Sample Web Api"
RUN dotnet build "Sample Web Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Sample Web Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Sample Web Api.dll"]