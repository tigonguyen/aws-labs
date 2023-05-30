output "id" {
  value = aws_vpc.main.id
}

output "publicSubnets" {
  value = aws_subnet.public
}

output "privateSubnets" {
  value = aws_subnet.private
}