output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "aws_lb_listener_prod" {
  value = aws_lb_listener.http.arn
}

output "aws_lb_listener_test" {
  value = aws_lb_listener.http_test.arn
}

output "aws_lb_target_group_prod" {
  value = aws_lb_target_group.tg_http.name
}

output "aws_lb_target_group_test" {
  value = aws_lb_target_group.tg_http_test.name
}