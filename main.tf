# Declare the data source
data "aws_availability_zones" "available" {}

#VPC Creation
resource "aws_vpc" "main" {
  cidr_block = "${var.cidr_range}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name = "my-test-terraform-vpc"
  }
}

#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "my-test-terraform-igw"
  }
}

#Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = {
    Name = "my-public-route-table"
  }
}

#Private Route Table
resource "aws_default_route_table" "private_route" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  tags = {
    Name = "my-default-route-table"
  }
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "{var.public_cidrs[count.index]}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "public-subnet-${count.index +1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "{var.private_cidrs[count.index]}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "public-subnet-${count.index +1}"
  }
}

#public subnet route table association
resource "aws_route_table_association" "pub_sub_assoc" {
  count          = "${aws_vpc.public_subnet.count}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.public_route.id}"
  depends_on     = {"aws_route_table.public_route","aws_subnet.public_subnet"}
}

#public subnet route table association
resource "aws_route_table_association" "priv_sub_assoc" {
  count          = "${aws_vpc.public_subnet.count}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.private_route.id}"
  depends_on     = {"aws_default_route_table.private_route","aws_subnet.public_subnet"}
}

#security Group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = {0.0.0.0/0 }
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = {0.0.0.0/0 }
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "-1"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = {0.0.0.0/0 }
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
  tags {
    Name = "my-test-terraform-securitygroup"
  }
}
