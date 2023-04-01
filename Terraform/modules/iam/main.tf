resource "aws_iam_role" "EcsServiceExecutionRole" {
  name = "EcsServiceExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "EcsServiceExecutionPolicy" {
  name = "EcsServiceExecutionPolicy"
  policy = file("modules/iam/ecsServiceExecutionPolicy.json")
}

resource "aws_iam_role_policy_attachment" "EcsServiceExecutionPolicyAttachment" {
  role       = aws_iam_role.EcsServiceExecutionRole.name
  policy_arn = aws_iam_policy.EcsServiceExecutionPolicy.arn
}