# Creating a Simple .NET Web API Service

In order to create a web API service in .NET we can do the following:

```
dotnet new webapi -o kafkaProducer --no-https
cd kafkaProducer
```

In this case I have named the project kafkaProducer since that is what I will be implementing later.

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

At this point we have a functional template service.  The default program mimicks a weather service.  To run the application locally (in Development mode) simply issue the command:

```
dotnet run
```

The startup messages will indicate the port the web server is listening on.  In my case the server was listening on [http://localhost:5253/](http://localhost:5253/).  You will have to look at the Controller file (in the Controllers folder) to see the URI mapping for the service.

---

[[back](../README.md#getting-started)]
