provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "a_vpc" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "a_sn_pub" {
  vpc_id                  = aws_vpc.a_vpc.id
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "a_sn_pvt" {
  vpc_id                  = aws_vpc.a_vpc.id
  cidr_block              = "10.0.0.16/28"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "a_igw" {
  vpc_id = aws_vpc.a_vpc.id
}

resource "aws_route_table" "a_rt" {
  vpc_id = aws_vpc.a_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.a_igw.id
  }
}

resource "aws_route_table_association" "a_rta" {
  subnet_id      = aws_subnet.a_sn_pub.id
  route_table_id = aws_route_table.a_rt.id
}

output "vpc_id" {
  value = aws_vpc.a_vpc.id
}

output "pub_sn_id" {
  value = aws_subnet.a_sn_pub.id
}

output "pvt_sn_id" {
  value = aws_subnet.a_sn_pvt.id
}
