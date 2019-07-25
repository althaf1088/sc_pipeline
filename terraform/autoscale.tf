## Creating Launch Configuration
resource "aws_launch_configuration" "terra_web" {
  image_id               = "${var.webservers_ami}"
  instance_type          = "t2.micro"
  security_groups = ["${aws_security_group.webservers.id}"]
  user_data = "${file("user_data.sh")}"
  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "terra_web_asg" {
  launch_configuration = "${aws_launch_configuration.terra_web.id}"
  availability_zones = ["${element(var.azs,count.index)}"]
  min_size = 2
  max_size = 3
  load_balancers = ["${aws_elb.terra-elb.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}