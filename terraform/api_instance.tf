resource "aws_instance" "webservers" {
  count = "${length(var.subnets_cidr)}"
  ami = "${var.webservers_ami}"
  instance_type = "${var.instance_type}"
  security_groups = [
    "${aws_security_group.webservers.id}"]
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  user_data = "${file("user_data.sh")}"

  tags {
    Name = "Server-${count.index}"
  }
}
  output "ec2_web" {
  value = ["${aws_instance.main.*.public_ip}"]
}

