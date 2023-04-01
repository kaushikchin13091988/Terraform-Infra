resource "aws_alb" "TestApplicationLoadBalancer" {
    name = "test-alb"
    internal = false
    load_balancer_type = "application"
    subnets = [
        var.public_subnet_1_id,
        var.public_subnet_2_id
    ]
    security_groups = [
        var.security_group_allow_http_traffic_id
    ]
    ip_address_type = "ipv4"
    access_logs {
        enabled = false
        bucket = ""
        prefix = ""
    }
    idle_timeout = "60"
    enable_deletion_protection = "false"
    enable_http2 = "true"
    enable_cross_zone_load_balancing = "true"
}

resource "aws_alb_listener" "TestAlbListener" {
    load_balancer_arn = aws_alb.TestApplicationLoadBalancer.arn
    port = 80
    protocol = "HTTP"
    default_action {
        fixed_response {
            content_type = "text/plain"
            status_code = "404"
        }
        type = "fixed-response"
    }
}

resource "aws_alb_listener_rule" "TestAlbListenerRule" {
    priority = "1"
    listener_arn = aws_alb_listener.TestAlbListener.arn
    condition {
        path_pattern {
            values = ["*/api/product/*"]
        }
    }
    action {
        type = "forward"
        #target_group_arn = "aws_alb_target_group.ProductServiceTargetGroup.arn"
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:385501908346:targetgroup/products-service-target-group/623025c9385fcf39"
    }
}

# resource "aws_alb_target_group" "ProductServiceTargetGroup" {
#   name     = "products-service-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
#   target_type = "ip"
# }

# resource "aws_alb_target_group_attachment" "ProductServiceTargetGroupAttachment" {
#   target_group_arn = aws_alb_target_group.ProductServiceTargetGroup.arn
#   target_id = var.ecs_id
# }