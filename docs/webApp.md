# Creating a Simple .NET Web App

In order to create a simple web application in .NET we can do the following:

```
dotnet new webapp -o myWebApp --no-https
cd myWebApp
```

Edit **appsettings.Development.json** to add `,"AllowedHosts": "*"` before last brace:

```
{
  "DetailedErrors": true,
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

## Running the Application Locally

To run the application locally (in Development mode) simply issue the command:

```
dotnet run
```

The startup messages will indicate the port the web server is listening on. In my case the server was listening on [http://localhost:5253/](http://localhost:5253/).

# Deploying the Application to OpenShift

There are two ways we can approach deploying the application to OpenShift.  The first is a more manual process of working with an existing binary.  Before doing so we will need to install the .NET image streams.  For instructions on installing the prerequisite image streams see here.

## Generating .NET Binaries Outside of OpenShift

When we are ready to build the application for deployment we can issue the following:

```
cd ..
dotnet publish myWebApp -f net7.0 -c Release
```

We can then deploy in OpenShift using the oc command as follows:

```
oc new-build --name=my-web-app dotnet:7.0-ubi8 --binary=true
oc start-build my-web-app --from-dir=myWebApp/bin/Release/net7.0/publish
oc logs -f bc/my-web-app
oc new-app my-web-app
oc status
oc expose svc/my-web-app
oc get route
```

## Leveraging Source-to-Image Deployment Strategy

If we store our application code in a git repository, we can have OpenShift pull and build the application directly from there.  The S2I process will also deploy the application.

```
oc new-project dotnet-project
oc new-app --name=dotnet-app \
   'dotnet:7.0-ubi8~https://github.com/ajhajj/dotNet#main' \
   --build-env DOTNET_STARTUP_PROJECT=myWebApp
oc logs -f bc/dotnet-app
oc logs -f deployment/dotnet-app
oc expose svc/dotnet-app
oc get routes
```

---

[[back](../README.md#getting-started)]
