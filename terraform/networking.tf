## Main VPC Configuration

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "three-tier-vpc"
  }
}


## Subnet Configuration

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

}

resource "aws_subnet" "private_app_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"

}


resource "aws_subnet" "private_db_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"

}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"

}


resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-central-1b"

}


resource "aws_subnet" "private_db_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-central-1b"

}


## IGW & Route Table Configuration

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "three-tier-igw"
  }
}

resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "public_traffic" {
  route_table_id         = aws_route_table.public_routing_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id

}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_routing_table.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_routing_table.id
}


## NAT Gateway Configuration

resource "aws_eip" "nat_a_eip" {
  domain = "vpc"
}

resource "aws_eip" "nat_b_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a_eip.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.main_igw]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b_eip.id
  subnet_id     = aws_subnet.public_b.id

  depends_on = [aws_internet_gateway.main_igw]
}



## NAT Routing Table


resource "aws_route_table" "private_app_a" {
  vpc_id = aws_vpc.main_vpc.id

}

resource "aws_route_table" "private_app_b" {
  vpc_id = aws_vpc.main_vpc.id


}

resource "aws_route" "private_app_a_traffic" {
  route_table_id         = aws_route_table.private_app_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_app_b_traffic" {
  route_table_id         = aws_route_table.private_app_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}


resource "aws_route_table_association" "private_app_a" {
  route_table_id = aws_route_table.private_app_a.id
  subnet_id      = aws_subnet.private_app_a.id
}

resource "aws_route_table_association" "private_app_b" {
  route_table_id = aws_route_table.private_app_b.id
  subnet_id      = aws_subnet.private_app_b.id
}