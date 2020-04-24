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
