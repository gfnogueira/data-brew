output "id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

#output "eip" {
#  value = var.public_instance ? aws_eip.this[0].public_ip : "No EIP Created"
#}