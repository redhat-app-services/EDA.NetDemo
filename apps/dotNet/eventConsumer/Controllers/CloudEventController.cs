using CloudNative.CloudEvents;
using Newtonsoft.Json.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using System.Web;
using System.Data.SqlClient;

namespace eventConsumer.Controllers;

[ApiController]
[Route("")]
public class CloudEventController : ControllerBase
{
  private readonly ILogger<CloudEventController> _logger;
  private static string conString = Environment.GetEnvironmentVariable("DB_CONN_STR") ?? "Plaintext";
  private static bool INSPECT = false;

  public CloudEventController(ILogger<CloudEventController> logger)
  {
    _logger = logger;
  }

  [HttpPost]
  public async Task<IActionResult> Test([FromBody] CloudEvent cloudEvent)
  {
    if (CloudEventController.INSPECT)
      return (await HttpRequestInspector());
    else
      return (ReceiveCloudEvent(cloudEvent));
  }

  private async Task<IActionResult> HttpRequestInspector()
  {
    using var bodyReader = new StreamReader(HttpContext.Request.Body);
    IHeaderDictionary headers = HttpContext.Request.Headers;
    IRequestCookieCollection cookies = HttpContext.Request.Cookies;

    Console.WriteLine("Cookies: \n----------------------------------");
    foreach (var (key, value) in cookies)
    {
      Console.WriteLine($"{key}: {value}");
    }

    Console.WriteLine("\nHeaders: \n----------------------------------");
    foreach (var (key, value) in headers)
    {
      Console.WriteLine($"{key}: {value}");
    }

    var body = await bodyReader.ReadToEndAsync();
    Console.WriteLine($"\nRequest Body:\n----------------------------------\n{body.ToString()}");

    return (Ok("Gotcha!"));
  }

  private IActionResult ReceiveCloudEvent(CloudEvent cloudEvent)
  {
    var attributeMap = new JObject();

    try
    {
      Console.WriteLine($"CloudEvent valid: {cloudEvent.IsValid}");

      if (cloudEvent.Data is null)
        Console.WriteLine($"CloudEvent Data: is null");
      else
        Console.WriteLine($"CloudEvent Data: {cloudEvent.Data.ToString()}");

      Console.WriteLine($"CloudEvent Source: {cloudEvent.Source}");
      Console.WriteLine($"CloudEvent Data content type: {cloudEvent.DataContentType}");

      var attributes = cloudEvent.GetPopulatedAttributes();
      int count = attributes.Count();
      Console.WriteLine($"Attribute count: {count}");
      if (count > 0)
      {
        Console.WriteLine("Attributes: ");
        foreach (var (attribute, value) in attributes)
        {
          attributeMap[attribute.Name] = attribute.Format(value);
          Console.WriteLine($"Name: {attribute.Name}, Value: {value}");
        }
      }
      if(CloudEventController.PersistMsg(cloudEvent))
        Console.WriteLine("Records Inserted Successfully");
  
    }
    catch (Exception e)
    {
      Console.WriteLine($"Oops, something went wrong: {e}");
    }
    Console.WriteLine($"{cloudEvent.GetAttribute("Id")}");
    Console.WriteLine($"Received event with ID {cloudEvent.Id}, attributes: {attributeMap}");
    
    return Ok($"Received event with ID {cloudEvent.Id}, attributes: {attributeMap}");
  }

  [HttpGet]
  public void ProcessHttpGet([FromQuery] String inspect)
  {
    var value = inspect ?? "false";

    CloudEventController.INSPECT = "true".Equals(inspect);
    Console.WriteLine("\n\n********************************************************************");
    Console.WriteLine($"Mode for HttpRequest inspection set to: {CloudEventController.INSPECT}");
    Console.WriteLine("Accessed using GET request. To change mode use '?inspect=true' or '?inspect=false' querystring parameter.");
    Console.WriteLine("********************************************************************\n");
  }

  private static bool PersistMsg(CloudEvent cloudEvent)
  {
    SqlConnection con = new SqlConnection(conString);
    
    //Parameterized query string
    String query = "INSERT INTO event_info (content_type, data) VALUES(@ContentType, @Data)";
    string msg;
    string contentType;
    bool success = true;

    SqlCommand cmd = new SqlCommand(query, con);
    
    msg = cloudEvent.Data.ToString() ?? "null";
    contentType = cloudEvent.DataContentType ?? "null";

    //Pass values to Parameters
    cmd.Parameters.AddWithValue("@ContentType", contentType);
    cmd.Parameters.AddWithValue("@Data", msg);

    try
    {
      con.Open();
      cmd.ExecuteNonQuery();
    }
    catch (SqlException e)
    {
      Console.WriteLine("Error Generated. Details: " + e.ToString());
      success = false;
    }
    finally
    {
      if(cmd is not null)
        cmd.Dispose();

      if(con is not null)
        con.Close();
    }
    return(success);
  }
}
