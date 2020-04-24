data "aws_elb_service_account" "current" {}

resource "aws_db_instance" "main" {
  copy_tags_to_snapshot        = true
  engine                       = "postgres"
  engine_version               = "11.5"
  identifier                   = "shopping"
  instance_class               = "db.t2.micro"
  max_allocated_storage        = 1000
  name                         = "covid19_shopping_assistant_production"
  performance_insights_enabled = true
  skip_final_snapshot          = true
  storage_encrypted            = false
}

resource "aws_instance" "main" {
  instance_type = "t2.2xlarge"
  ami           = "ami-035966e8adab4aaad"
}

resource "aws_s3_bucket" "logs" {
  bucket = "possoir-production-logs"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::possoir-production-logs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.current.arn}"
        ]
      }
    }
  ]
}
POLICY
}

resource "aws_lb" "api" {
  name = "api"

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    enabled = true
  }
}

resource "aws_lb_listener" "api_http" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_acm_certificate" "api" {
  domain = "*.posso-ir.com"
}

resource "aws_lb_listener" "api_https" {
  load_balancer_arn = aws_lb.api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.api.arn

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name = "api"

  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    path    = "/"
    matcher = "200,301"
  }
}

resource "aws_lb_target_group_attachment" "api" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.main.id
  port             = 80
}

resource "aws_route53_zone" "puedo_ir_com" {
  name = "puedo-ir.com."
}

resource "aws_route53_zone" "puedo_ir_es" {
  name = "puedo-ir.es."
}

resource "aws_route53_zone" "can_i_go_co_uk" {
  name = "can-i-go.co.uk."
}

resource "aws_route53_zone" "necakajvrade_com" {
  name = "necakajvrade.com."
}
