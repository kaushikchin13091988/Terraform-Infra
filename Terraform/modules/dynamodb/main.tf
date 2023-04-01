resource "aws_dynamodb_table" "ProductsDynamoDbTable" {
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "category"
    name           = "products"
    range_key      = "name"
    read_capacity  = 0
    stream_enabled = false
    table_class    = "STANDARD"
    tags           = {}
    tags_all       = {}
    write_capacity = 0

    attribute {
        name = "category"
        type = "S"
    }
    attribute {
        name = "name"
        type = "S"
    }

    point_in_time_recovery {
        enabled = false
    }

    timeouts {}

    ttl {
        attribute_name = "TimeToExist"
        enabled        = false
  }
}