output "ecs_service_id" {
  value = aws_ecs_service.ProductsServiceECSService.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.TestECSCluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ProductsServiceECSService.name
}