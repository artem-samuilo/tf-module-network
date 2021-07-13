output "vpc_id" {
    value = aws_vpc.main.id
}

output "vpc_cidr" {
    value = aws_vpc.main.cidr_block
}

output "aws_igw" {
    value = aws_internet_gateway.aws-igw.id
}

output "aws_nat_gateway" {
    value = aws_nat_gateway.nat_gw[*].id
}

output "public_subnets_ids" {
    value = aws_subnet.aws_subnet_public[*].id
}

output "private_subnets_ids" {
    value = aws_subnet.aws_subnet_private[*].id
}

