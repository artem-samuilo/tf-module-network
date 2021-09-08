resource "aws_vpc" "main" {
    cidr_block               = var.vpc_cidr
    tags = {
     Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "aws-igw" {
    vpc_id                   = aws_vpc.main.id
    tags = {
     Name = "${var.env}-vpc-igw"
  }

}

resource "aws_subnet" "aws_subnet_private" {
    vpc_id                  = "${aws_vpc.main.id}"
    count                   = var.private_subnets_count
    cidr_block              = cidrsubnet("${var.vpc_cidr}", var.newbits, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = "false"
    tags = {
     Name = "aws_subnet_private-${count.index + 1}"
    }
}

resource "aws_subnet" "aws_subnet_public" {
    vpc_id                  = "${aws_vpc.main.id}"
    count                   = var.public_subnets_count
    cidr_block              = cidrsubnet("${var.vpc_cidr}", var.newbits, count.index + var.private_subnets_count)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = "true"
    tags = {
     Name = "aws_subnet_public-${count.index + 1}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
     Name = "${var.env}-vpc-routing-table-public"
  }
}

resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.aws-igw.id
}

resource "aws_route_table_association" "public" {
    count                  = var.public_subnets_count
    subnet_id              = element(aws_subnet.aws_subnet_public.*.id, count.index)
    route_table_id         = aws_route_table.public.id
}

resource "aws_eip" "aws_eip" {
    vpc                    = true
    count                  = var.private_subnets_count
    depends_on             = [aws_internet_gateway.aws-igw]
}

resource "aws_nat_gateway" "nat_gw" {
    connectivity_type      = "public"
    count                  = var.private_subnets_count
    allocation_id          = "${aws_eip.aws_eip[count.index].id}"
    subnet_id              = element(aws_subnet.aws_subnet_public.*.id, 0)
    depends_on             = [aws_internet_gateway.aws-igw]
    tags = {
     Name = "${var.env}-vpc-NAT_GW"
  }
}

resource "aws_route_table" "private" {
    vpc_id                 = aws_vpc.main.id
    count                  = var.private_subnets_count
    route {
        cidr_block             = "0.0.0.0/0"
        nat_gateway_id             = aws_nat_gateway.nat_gw[count.index].id
    }
    tags = {
     Name = "${var.env}-vpc-routing-table-private"
  }
}

resource "aws_route_table_association" "private" {
    count                  = var.private_subnets_count
    subnet_id              = element(aws_subnet.aws_subnet_private.*.id, count.index)
    route_table_id         = aws_route_table.private[count.index].id
}
