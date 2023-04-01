using Amazon.DynamoDBv2.DataModel;
using Amazon.DynamoDBv2.DocumentModel;
using AWS.Demo.DynamoDB.Models;
using Microsoft.AspNetCore.Mvc;

namespace AWS.Demo.DynamoDB.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IDynamoDBContext _dynamoDBContext;
        private readonly ILogger<ProductController> _logger;

        public ProductController(IDynamoDBContext dynamoDBContext, ILogger<ProductController> logger)
        {
            _dynamoDBContext = dynamoDBContext;
            _logger = logger;
        }

        [HttpGet]
        [Route("health")]
        public async Task<IActionResult> Get()
        {
            _logger.LogInformation("Calling health check Api");
            return Ok("Health check success");
        }

        [Route("{category}/{productName}")]
        [HttpGet]
        public async Task<IActionResult> Get(string category, string productName)
        {
            _logger.LogInformation("Calling Api to get product");
            var product = await _dynamoDBContext.LoadAsync<Product>(category, productName);
            return Ok(product);
        }

        [HttpPost]
        public async Task<IActionResult> Save(Product product)
        {
            _logger.LogInformation("Calling Api to save product");
            await _dynamoDBContext.SaveAsync(product);
            return Ok();
        }

        [Route("{category}/{productName}")]
        [HttpDelete]
        public async Task<IActionResult> Delete(string category, string productName)
        {
            _logger.LogInformation("Calling Api to delete product");
            await _dynamoDBContext.DeleteAsync<Product>(category, productName);
            return Ok();
        }

        [Route("search/{category}")]
        [HttpGet]
        public async Task<IActionResult> Search(string category, string? productName = null, decimal? price = null)
        {
            _logger.LogInformation("Calling Api to search product");

            // 1. Construct QueryFilter
            var queryFilter = new QueryFilter("category", QueryOperator.Equal, category);

            if (!string.IsNullOrEmpty(productName))
            {
                queryFilter.AddCondition("name", ScanOperator.Equal, productName);
            }

            if (price.HasValue)
            {
                queryFilter.AddCondition("price", ScanOperator.LessThanOrEqual, price);
            }

            // 2. Construct QueryOperationConfig
            var queryOperationConfig = new QueryOperationConfig
            {
                Filter = queryFilter
            };

            // 3. Create async search object
            var search = _dynamoDBContext.FromQueryAsync<Product>(queryOperationConfig);

            // 4. Finally get all the data in a singleshot
            var searchResponse = await search.GetRemainingAsync();

            // Return it
            return Ok(searchResponse);
        }
    }
}
