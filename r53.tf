data "aws_region" "current" {}

resource "aws_route53_zone" "main" {
  name = "${var.site_name}"
}

resource "aws_route53_record" "main" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "${var.site_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "www.${var.site_name}"
  type    = "CNAME" # When using A-record Terraform Apply works, but www.whynot.guide never resolves.

  alias {
    name                   = "${aws_s3_bucket.www.website_endpoint}"
    zone_id                = "${aws_s3_bucket.www.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_name}"
  type    = "${tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_type}"
  zone_id = "${aws_route53_zone.main.id}"
  records = ["${tolist(aws_acm_certificate.cert.domain_validation_options).0.resource_record_value}"]
  ttl     = 60
}