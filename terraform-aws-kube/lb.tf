resource "aws_lb" "app-k8s" {
  name               = "app-k8s"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.sb-pub-k8s-a.id,aws_subnet.sb-pub-k8s-b.id,aws_subnet.sb-pub-k8s-c.id]

}

resource "aws_lb_target_group" "tg-k8s" {
  name     = "tg-k8s"
  port     = 30009
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC-K8S.id

  health_check {
    path = "/"
    port = 30009
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 2
    interval = 5
    matcher = "200"
  }

}

resource "aws_alb_listener" "app-k8s-listener" {

  load_balancer_arn = aws_lb.app-k8s.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}

resource "aws_lb_listener" "app-k8s-listener-443" {
  load_balancer_arn = aws_lb.app-k8s.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_iam_server_certificate.test_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-k8s.arn
  }
}
