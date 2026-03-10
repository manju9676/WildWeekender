resource "aws_vpc" "myvpc" {
  tags = {
    Name = "myvpc"
  }
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "public-subnet-1" {
  vpc_id = aws_vpc.myvpc.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
    tags = {
        Name = "public-subnet-1"
    }
}
resource "aws_subnet" "public-subnet-2" {
  vpc_id = aws_vpc.myvpc.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
  cidr_block = "10.0.2.0/24"
    tags = {
        Name = "public-subnet-2"
    }
}
resource "aws_subnet" "private-subnet-1" {
  vpc_id = aws_vpc.myvpc.id
  map_public_ip_on_launch = false
  cidr_block = "10.0.3.0/24"
    tags = {
        Name = "private-subnet-1"
    }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
    tags = {
        Name = "myigw"
    }
}
resource "aws_route_table" "rt1" {
    vpc_id = aws_vpc.myvpc.id
        tags = {
            Name = "public-route-table"
        }
    
}

resource "aws_route_table_association" "rta-1" {
  route_table_id = aws_route_table.rt1.id
  subnet_id = aws_subnet.public-subnet-1.id
}
resource "aws_route_table_association" "rta-2" {
  route_table_id = aws_route_table.rt1.id
  subnet_id = aws_subnet.public-subnet-2.id
}
resource "aws_route" "rt" {
  route_table_id = aws_route_table.rt1.id
  destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}
