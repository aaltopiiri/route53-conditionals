provider "aws" {
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
  region                  = var.region
}
data "aws_route53_zone" "zone" {
  name = var.zone_name
}
resource "aws_route53_record" "mx-1" {
  count   = var.is_mx ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = ""
  type    = "MX"
  records = [
    "1 ASPMX.L.GOOGLE.COM",
    "5 ALT1.ASPMX.L.GOOGLE.COM",
    "5 ALT2.ASPMX.L.GOOGLE.COM",
    "10 ASPMX2.GOOGLEMAIL.COM",
    "10 ASPMX3.GOOGLEMAIL.COM",
  ]

  ttl = var.ttl
}
resource "aws_route53_record" "cname-1" {
  count   = var.is_cname ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "mail"
  type    = "CNAME"
  records = ["ghs.google.com"]
  ttl     = var.ttl
}
resource "aws_route53_record" "cname-2" {
  count   = var.is_cname ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "cal"
  type    = "CNAME"
  records = ["ghs.google.com"]
  ttl     = var.ttl
}
resource "aws_route53_record" "cname-3" {
  count   = var.is_cname ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "docs"
  type    = "CNAME"
  records = ["ghs.google.com"]
  ttl     = var.ttl
}

module "acm_request_certificate" {
  source                            = "git::https://github.com/cloudposse/terraform-aws-acm-request-certificate.git?ref=tags/0.7.0"
  domain_name                       = "${var.zone_name}"
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = ["*.${var.zone_name}"]
}


//Region us-east-1 (North Virginia)  
//Latency Policy

resource "aws_route53_record" "a-latency-us-east-1" {
  count   = var.is_alb ? 1 : 0  
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "${var.zone_name}"
  type           = "A"
  set_identifier = "cdp-tds-us-east-1-a"
  latency_routing_policy {
    region = "us-east-1"
  }
  alias {
    name                   = "cdp-tds-alb-4d-930437359.us-east-1.elb.amazonaws.com."
    zone_id                = "${var.elb_us_zone_id}"
    evaluate_target_health = false
  }
}



resource "aws_route53_record" "aaaa-latency-us-east-1" {
    count   = var.is_alb ? 1 : 0
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "${var.zone_name}"
  type           = "AAAA"
  set_identifier = "cdp-tds-us-east-1-aaaa"
  latency_routing_policy {
    region = "us-east-1"
  }
  alias {
    name                   = "cdp-tds-alb-4d-930437359.us-east-1.elb.amazonaws.com."
    zone_id                = "${var.elb_us_zone_id}"
    evaluate_target_health = false
  }
}

//Region eu-west-1 (Dublin) 
//Failover Policy

resource "aws_route53_record" "a-failover-primary-eu-west-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "eu-west-1.${var.zone_name}"
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "eu-west-1-primary-a"
  alias {
    name                   = "cdp-tds-eu-west-alb-4d-429299911.eu-west-1.elb.amazonaws.com."
    zone_id                = "${var.elb_eu_zone_id}"
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "a-failover-secondary-eu-west-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "eu-west-1.${var.zone_name}"
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "eu-west-1-secondary-a"
  alias {
    name                   = "cdp-tds-alb-4d-930437359.us-east-1.elb.amazonaws.com."
    zone_id                = "${var.elb_us_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aaaa-failover-primary-eu-west-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "eu-west-1.${var.zone_name}"
  type    = "AAAA"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "eu-west-1-primary-aaaa"
  alias {
    name                   = "cdp-tds-eu-west-alb-4d-429299911.eu-west-1.elb.amazonaws.com."
    zone_id                = "${var.elb_eu_zone_id}"
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "aaaa-failover-secondary-eu-west-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "eu-west-1.${var.zone_name}"
  type    = "AAAA"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "eu-west-1-secondary-aaaa"
  alias {
    name                   = "cdp-tds-alb-4d-930437359.us-east-1.elb.amazonaws.com."
    zone_id                = "${var.elb_us_zone_id}"
    evaluate_target_health = true
  }
}

//Latency Policy eu-west-1

resource "aws_route53_record" "a-latency-eu-west-1" {
  count   = var.is_alb ? 1 : 0
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "${var.zone_name}"
  type           = "A"
  set_identifier = "cdp-tds-eu-west-1-a"
  latency_routing_policy {
    region = "eu-west-1"
  }
  alias {
    name                   = "eu-west-1.${var.zone_name}."
    zone_id                = data.aws_route53_zone.zone.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa-latency-eu-west-1" {
  count   = var.is_alb ? 1 : 0
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "${var.zone_name}"
  type           = "AAAA"
  set_identifier = "cdp-tds-eu-west-1-aaaa"
  latency_routing_policy {
    region = "eu-west-1"
  }
  alias {
    name                   = "eu-west-1.${var.zone_name}."
    zone_id                = data.aws_route53_zone.zone.zone_id
    evaluate_target_health = false
  }
}

//Region ap-south-1 (Mumbai) 

resource "aws_route53_record" "a-failover-primary-ap-south-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "ap-south-1.${var.zone_name}"
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "ap-south-1-primary-a"
  alias {
    name                   = "cdp-tds-ap-south-alb-4d-1293711515.ap-south-1.elb.amazonaws.com."
    zone_id                = "${var.elb_ap_zone_id}"
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "a-failover-secondary-ap-south-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "ap-south-1.${var.zone_name}"
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "ap-south-1-secondary-a"
  alias {
    name                   = "cdp-tds-alb-4d-930437359.us-east-1.elb.amazonaws.com."
    zone_id                = "${var.elb_us_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aaaa-failover-primary-ap-south-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "ap-south-1.${var.zone_name}"
  type    = "AAAA"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "ap-south-1-primary-aaaa"
  alias {
    name                   = "cdp-tds-ap-south-alb-4d-1293711515.ap-south-1.elb.amazonaws.com."
    zone_id                = "${var.elb_ap_zone_id}"
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "aaaa-failover-secondary-ap-south-1" {
  count   = var.is_alb ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "ap-south-1.${var.zone_name}"
  type    = "AAAA"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "ap-south-1-secondary-aaaa"
  alias {
    name                   = "cdp-tds-alb-4d-930437359.us-east-1.elb.amazonaws.com."
    zone_id                = "${var.elb_us_zone_id}"
    evaluate_target_health = true
  }
}

//Latency Policy ap-south-1

resource "aws_route53_record" "a-latency-ap-south-1" {
  count   = var.is_alb ? 1 : 0
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "${var.zone_name}"
  type           = "A"
  set_identifier = "cdp-tds-ap-south-1-a"
  latency_routing_policy {
    region = "ap-south-1"
  }
  alias {
    name                   = "ap-south-1.${var.zone_name}."
    zone_id                = data.aws_route53_zone.zone.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa-latency-ap-south-1" {
  count   = var.is_alb ? 1 : 0
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "${var.zone_name}"
  type           = "AAAA"
  set_identifier = "cdp-tds-ap-south-1-aaaa"
  latency_routing_policy {
    region = "ap-south-1"
  }
  alias {
    name                   = "ap-south-1.${var.zone_name}."
    zone_id                = data.aws_route53_zone.zone.zone_id
    evaluate_target_health = false
  }
}