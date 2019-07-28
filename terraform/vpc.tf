# VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "TerraVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  tags {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "public" {
  count                   = "${length(var.subnets_cidr)}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  cidr_block              = "${element(var.subnets_cidr,count.index)}"
  availability_zone       = "${element(var.azs,count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "Subnet-${count.index+1}"
  }
}

resource "aws_db_subnet_group" "sc_subnetgroup" {
  name = "sc_subnetgroup"

  subnet_ids = ["${aws_subnet.public.*.id}"]

  tags {
    Name = "sc_subnet_group"
  }
}

# Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_igw.id}"
  }

  tags {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = "${length(var.subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "wp_db" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "10.6"
  instance_class         = "db.t2.micro"
  name                   = "sc"
  username               = "postgres"
  password               = "123nextstar"
  db_subnet_group_name   = "${aws_db_subnet_group.sc_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.webservers.id}"]
  skip_final_snapshot    = true
}
