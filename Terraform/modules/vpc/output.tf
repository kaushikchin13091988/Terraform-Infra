output "vpc_id" {
  value = aws_vpc.TestVpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.TestPublicSubnet2.id
}

output "public_subnet_2_id" {
  value = aws_subnet.TestPublicSubnet1.id
}

output "private_subnet_1_id" {
  value = aws_subnet.TestPrivateSubnet1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.TestPrivateSubnet2.id
}