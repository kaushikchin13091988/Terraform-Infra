output "alb_id" {
  value = aws_alb.TestApplicationLoadBalancer.id
}

output "target_group_id" {
  value = aws_alb_target_group.ProductServiceTargetGroup.arn
}