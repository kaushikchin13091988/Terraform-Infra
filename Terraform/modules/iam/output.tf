output "ecsServiceExecutionRole_id" {
  value = aws_iam_role.EcsServiceExecutionRole.arn
}

output "ecsServiceTaskRole_id" {
  value = aws_iam_role.EcsServiceTaskRole.arn
}