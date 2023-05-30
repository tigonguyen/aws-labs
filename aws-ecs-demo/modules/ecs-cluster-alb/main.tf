# Create SG for LB
resource "aws_security_group" "loadBalancerSG" {
  name   = "${var.env}-loadBalancerSG"
  vpc_id = var.vpcID

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


# Define a load balancer on AWS
resource "aws_lb" "loadBalancer" {
  name               = "${var.env}-loadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadBalancerSG.id]
  subnets            = var.subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name = "${var.env} Load Balancer"
    Env  = "${var.env}"
  }
}

resource "aws_alb_target_group" "loadBalancerTG1" {
  name        = "${var.env}-loadBalancerTG-1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpcID
  target_type = "ip"
}

resource "aws_alb_target_group" "loadBalancerTG2" {
  name        = "${var.env}-loadBalancerTG-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpcID
  target_type = "ip"
}

# HTTP Listener redirect to HTTPS 
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.loadBalancer.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.loadBalancer.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.loadBalancerTG1.id
    type             = "forward"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Name = "${var.env} TLS cert"
    Env  = "${var.env}"
  }
}
