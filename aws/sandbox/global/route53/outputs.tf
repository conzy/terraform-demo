output "nameservers" {
  value = aws_route53_zone.sandbox.name_servers
}
