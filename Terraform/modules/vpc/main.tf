#VPC
resource "aws_vpc" "TestVpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test-vpc"
  }
}

#Internet gateway
resource "aws_internet_gateway" "TestIgw" {
    vpc_id = "${aws_vpc.TestVpc.id}"
    tags = {
        Name = "test-igw"
    }
}

#Private subnets
resource "aws_subnet" "TestPrivateSubnet1" {
  vpc_id     = aws_vpc.TestVpc.id
  cidr_block = "10.0.0.0/24"
  #availability_zone = "${aws_vpc.TestVpc.region}a"
  availability_zone = "${var.region}a"
  tags = {
    Name = "test-private-subnet-1"
  }
}

resource "aws_subnet" "TestPrivateSubnet2" {
  vpc_id     = aws_vpc.TestVpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "test-private-subnet-2"
  }
}

#Public subnets
resource "aws_subnet" "TestPublicSubnet2" {
  vpc_id     = aws_vpc.TestVpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "test-public-subnet-2"
  }
}

resource "aws_subnet" "TestPublicSubnet1" {
  vpc_id     = aws_vpc.TestVpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "test-public-subnet-1"
  }
}

#Route tables
resource "aws_route_table" "TestPrivateRouteTable" {
  vpc_id = aws_vpc.TestVpc.id

  tags = {
    Name = "test-private-route-table"
  }
}

resource "aws_route_table" "TestPublicRouteTable" {
  vpc_id = aws_vpc.TestVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TestIgw.id
  }

  tags = {
    Name = "test-public-route-table"
  }
}

#Route table associations
resource "aws_route_table_association" "TestPrivateRouteTableAssociation1" {
  subnet_id      = aws_subnet.TestPrivateSubnet1.id
  route_table_id = aws_route_table.TestPrivateRouteTable.id
}

resource "aws_route_table_association" "TestPrivateRouteTableAssociation2" {
  subnet_id      = aws_subnet.TestPrivateSubnet2.id
  route_table_id = aws_route_table.TestPrivateRouteTable.id
}

resource "aws_route_table_association" "TestPublicRouteTableAssociation1" {
  subnet_id      = aws_subnet.TestPublicSubnet2.id
  route_table_id = aws_route_table.TestPublicRouteTable.id
}

resource "aws_route_table_association" "TestPublicRouteTableAssociation2" {
  subnet_id      = aws_subnet.TestPublicSubnet1.id
  route_table_id = aws_route_table.TestPublicRouteTable.id
}