resource "aws_vpc" "vpc10" {
  cidr_block = "10.${var.num}.0.0/16"
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "igw10" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    Name = "${var.env}-igw"
  }

}

resource "aws_route_table" "rt10" {
  vpc_id = aws_vpc.vpc10.id
  route {
    cidr_block = var.route_cidr_block
    gateway_id = aws_internet_gateway.igw10.id
  }

  tags = {
    Name = "${var.env}-route-table"
  }
}

