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

# Subnets : private
resource "aws_subnet" "private" {
  count                   = "${length(var.private_subnets_cidr)}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  cidr_block              = "${element(var.private_subnets_cidr,count.index)}"
  availability_zone       = "${element(var.azs,count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "Subnet-${count.index+1}"
  }
}

resource "aws_db_subnet_group" "sc_subnetgroup" {
  name = "sc_subnetgroup"

  subnet_ids = ["${aws_subnet.private.*.id}"]

  tags {
    Name = "sc_subnet_group"
  }
}

#RDS Security Group
resource "aws_security_group" "sc_rds_sg" {
  name        = "wp_rds_sg"
  description = "Used for DB instances"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  # SQL access from public/private security group

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = ["${aws_security_group.webservers.id}"
    ]
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

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = "${aws_vpc.terra_vpc.default_route_table_id}"

  tags {
    Name = "sc_private"
  }
}
# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = "${length(var.subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# Route table association with private subnets
resource "aws_route_table_association" "b" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private.*.id,count.index)}"
  route_table_id = "${aws_default_route_table.private_rt.id}"
}


resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
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
  vpc_security_group_ids = ["${aws_security_group.sc_rds_sg.id}"]
  skip_final_snapshot    = true
}
