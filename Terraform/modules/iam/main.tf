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

resource "aws_iam_policy" "AmazonDynamoDBFullAccess" {
  name = "AmazonDynamoDBFullAccess"
  policy = file("modules/iam/AmazonDynamoDBFullAccess.json")
}

resource "aws_iam_policy" "AmazonECS_FullAccess" {
  name = "AmazonECS_FullAccess"
  policy = file("modules/iam/AmazonECS_FullAccess.json")
}

resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccessAttachment" {
  role       = aws_iam_role.EcsServiceTaskRole.name
  policy_arn = aws_iam_policy.AmazonDynamoDBFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AmazonECS_FullAccessAttachment" {
  role       = aws_iam_role.EcsServiceTaskRole.name
  policy_arn = aws_iam_policy.AmazonECS_FullAccess.arn
}

// ---------------------------------------------------------------------------------------------------------

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

resource "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  name = "AmazonECSTaskExecutionRolePolicy"
  policy = file("modules/iam/AmazonECSTaskExecutionRolePolicy.json")
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicyAttachment" {
  role       = aws_iam_role.EcsServiceExecutionRole.name
  policy_arn = aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}