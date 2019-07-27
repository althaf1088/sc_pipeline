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
        EOD
          }
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.webservers.id}  && ansible-playbook -e host_key_checking=False -i aws_hosts python3.yml --private-key=~/.ssh/sc_deploy "
  }
}

#load balancer

resource "aws_elb" "terra_elb" {


  subnets         = ["${aws_subnet.public.*.id}"]

  security_groups = ["${aws_security_group.webservers.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "sc-terra-elb"
  }
}


#AMI
resource "aws_ami_from_instance" "wp_golden" {
  name               = "sc-ami-0ff8a91517f17f867"
  source_instance_id = "${aws_instance.webservers.id}"

}



## Creating Launch Configuration
resource "aws_launch_configuration" "terra_web_lc" {
  name_prefix     = "sc_lc-"
  image_id        = "${aws_ami_from_instance.wp_golden.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.webservers.id}"]
  user_data       = "${file("user_data.sh")}"
  key_name        = "${aws_key_pair.wp_auth.id}"

  lifecycle {
    create_before_destroy = true
  }
}

#ASG

#resource "random_id" "rand_asg" {
# byte_length = 8
#}

resource "aws_autoscaling_group" "terra_web_asg" {
  name                      = "asg-${aws_launch_configuration.terra_web_lc.id}"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = "300"
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  load_balancers            = ["${aws_elb.terra_elb.id}"]



  launch_configuration = "${aws_launch_configuration.terra_web_lc.name}"

  tag {
    key                 = "Name"
    value               = "wp_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


