#key pair

resource "aws_key_pair" "wp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "webservers" {
  ami = "${var.webservers_ami}"
  key_name = "${aws_key_pair.wp_auth.id}"
  instance_type = "${var.instance_type}"
  security_groups = [
    "${aws_security_group.webservers.id}"]
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  user_data = "${file("user_data.sh")}"

  tags {
    Name = "devServer"
  }
  provisioner "local-exec" {
            command = <<EOD
        cat <<EOF > aws_hosts
        [web]
        ${aws_instance.webservers.public_ip} ansible_user=ec2-user
        EOF
        EOD
          }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.webservers.id}  && ansible-playbook -i aws_hosts python3.yml"
  }
}




