output "server_ip" {
  value = aws_instance.server[0].public_ip
}
# output "server_id" {
#   value = aws_instance.server[0].id
# }
# output "remote_backend" {
#   value = data.aws_s3_bucket.remote-backend.arn
# }
# output "azs" {
#   value = data.aws_availability_zones.available.names
# }
# output "website_endpoint" {
#   value = "http://${data.aws_s3_bucket.legacy_import.website_endpoint}/"
# }
output "myip" {
  value = chomp(data.http.icanhazip.response_body)
}
output "server_dns" {
  value = "http://${aws_instance.server[0].public_dns}"
}
