
resource "aws_appautoscaling_policy" "AutoScalingPolicy" {
  name = "products-service-scaling-policy"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.AutoScalingTarget.resource_id
  scalable_dimension = aws_appautoscaling_target.AutoScalingTarget.scalable_dimension
  service_namespace = aws_appautoscaling_target.AutoScalingTarget.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
    scale_in_cooldown  = 2
    scale_out_cooldown = 2
  }
}

resource "aws_appautoscaling_target" "AutoScalingTarget" {
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.TestECSCluster.name}/${aws_ecs_service.ECSProductsService.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_ecs_service" "ECSProductsService" {
    name = "products-ecs-service"
    cluster = aws_ecs_cluster.TestECSCluster.arn
    load_balancer {
        target_group_arn = var.target_group_id
        container_name = "products-service"
        container_port = 80
    }
    desired_count = 2
    launch_type = "FARGATE"
    platform_version = "LATEST"
    task_definition = aws_ecs_task_definition.ProductsServiceECSTaskDefinition.arn
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 100
    network_configuration {
        assign_public_ip = "true"
        security_groups = [
            var.security_group_allow_http_traffic_id
        ]
        subnets = [
            var.public_subnet_1_id,
            var.public_subnet_2_id
        ]
    }
    health_check_grace_period_seconds = 0
    scheduling_strategy = "REPLICA"
}

resource "aws_ecs_cluster" "TestECSCluster" {
  name = "test-ecs-cluster"
}

resource "aws_ecs_task_definition" "ProductsServiceECSTaskDefinition" {
  family = "products-service-ecs-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu       = 256
  memory    = 512
  execution_role_arn       = aws_iam_role.EcsServiceExecutionRole.arn
  task_role_arn            = aws_iam_role.EcsServiceTaskRole.arn
  container_definitions = jsonencode([
    {
      name      = "products-service"
      image     = "385501908346.dkr.ecr.us-east-1.amazonaws.com/products-service:latest" 
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_iam_role" "EcsServiceTaskRole" {
  name = "EcsServiceTaskRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy" "DynamoDBCrudOperationsPolicy" {
  name = "DynamoDBCrudOperationsPolicy"
  policy = file("modules/ecs/DynamoDBCrudOperationsPolicy.json")
}

resource "aws_iam_role_policy_attachment" "DynamoDBCrudOperationsPolicyAttachment" {
  role       = aws_iam_role.EcsServiceTaskRole.name
  policy_arn = aws_iam_policy.DynamoDBCrudOperationsPolicy.arn
}

resource "aws_iam_role_policy_attachment" "AmazonECS_FullAccessPolicyAttachment" {
  role       = aws_iam_role.EcsServiceTaskRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "CloudWatchFullAccessPolicyAttachment" {
  role       = aws_iam_role.EcsServiceTaskRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role" "EcsServiceExecutionRole" {
  name = "EcsServiceExecutionRole"

  assume_role_policy = jsonencode({
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicyAttachment" {
  role       = aws_iam_role.EcsServiceExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
