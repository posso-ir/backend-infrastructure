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
  instance_type        = "t2.2xlarge"
  ami                  = "ami-035966e8adab4aaad"
  iam_instance_profile = aws_iam_instance_profile.main.name

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

resource "aws_iam_role_policy" "main_instance_send_emails" {
  name = "main_instance_send_emails"
  role = aws_iam_role.main_instance.id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "main_instance" {
  name = "main_instance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "main" {
  name = "main"
  role = aws_iam_role.main_instance.name
}
