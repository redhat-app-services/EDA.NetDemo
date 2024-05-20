using System;
using System.Text;
using Confluent.Kafka;
using Microsoft.AspNetCore.Mvc;
namespace kafkaProducer.Controllers
{
    [Route("api/kafka")]
    [ApiController]
    public class KafkaProducerController : ControllerBase
    {
        private static string cfgSecurityProto = Environment.GetEnvironmentVariable("KAFKA_SEC_PROTO") ?? "Plaintext";
        private static SecurityProtocol securityProto = "Ssl".Equals(cfgSecurityProto) ? SecurityProtocol.Ssl : SecurityProtocol.Plaintext;
        private readonly string topic = Environment.GetEnvironmentVariable("KAFKA_TOPIC") ?? "default-topic";
        private readonly ProducerConfig config = new ProducerConfig
        {
            BootstrapServers = Environment.GetEnvironmentVariable("KAFKA_BOOTSTRAP"),
            SecurityProtocol = securityProto,
            SslCaLocation = Environment.GetEnvironmentVariable("KAFKA_SSL_CA_LOC"),
            ClientId = Environment.GetEnvironmentVariable("KAFKA_PROD_CLIENTID")
        };

        [HttpPost]
        public IActionResult Post()
        {
            String message = HttpContext.Request.Form["message"].ToString();
            Console.WriteLine($"Received: {message}");
            String msg = message ?? "{ \"message\": \"Hello World!!\" }";
            return Created(string.Empty, SendToKafka(topic, msg));
        }

        private Object SendToKafka(string topic, string message)
        {
            Object result = "";
            Headers headers = new();
            string value;

            if(message.Trim().StartsWith("{", StringComparison.CurrentCultureIgnoreCase))
              value = message;
            else
              value = "{\"message\": \"" + message + "\"}";

            using (var producer = new ProducerBuilder<Null, string>(config).Build())
            {
                headers.Add("Content-Type", Encoding.UTF8.GetBytes("application/json"));
                try
                {
                    return producer.ProduceAsync(topic, new Message<Null, string> { Value = value, Headers = headers })
                        .GetAwaiter()
                        .GetResult();
                }
                catch (Exception e)
                {
                    Console.WriteLine($"Oops, something went wrong: {e}");
                }
            }

            return result;
        }
    }
}
