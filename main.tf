provider "aws" {
				region = "us-east-1"
}
#launch template
resource "aws_launch_template" "aws-LT" {
  name_prefix   = "aws-LT"
  image_id      = "ami-0f9fc25dd2506cf6d"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-0c8b9feb51abf788b"]
  key_name = "aws-freetair-key"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tf_lt"
    }
  }
  metadata_options {
    instance_metadata_tags      = "enabled"
  }  
}
#auto scaling group
resource "aws_autoscaling_group" "aws-ASG" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.aws-LT.id
    version = "$Latest"
  }
}
#auto scaling attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.aws-ASG.id

}
#applcation load balancer
resource "aws_lb" "aws_lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  #security_groups    = "sg-0c8b9feb51abf788b"
  subnets            = [aws_default_subnet.default_subnet.id , aws_default_subnet.default_subnet_2.id]

  #enable_deletion_protection = true

  tags = {
    Environment = "tf-alb-tag"
  }
}
#network load balancer
resource "aws_lb" "nlb" {
    name               = "test-nlb-tf"
    internal           = false
    load_balancer_type = "network"
    subnets            = [aws_default_subnet.default_subnet.id , aws_default_subnet.default_subnet_2.id] 
}
#load balancer target group
resource "aws_lb_target_group" "aws-lb-tg" {
  name        = "tf-example-lb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = "vpc-0f4b3f0a105ba3286"
}
#load balancer target group attachment
resource "aws_lb_target_group_attachment" "lb-with-tg" {
  target_group_arn = aws_lb_target_group.aws-lb-tg.arn
  target_id        = aws_lb.aws_lb.arn
  port             = 80
}
#load balancer listener
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws-lb-tg.arn
  }
}
#subnet1
resource "aws_default_subnet" "default_subnet" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-default-subnet"
  }
}
#subnet2
resource "aws_default_subnet" "default_subnet_2" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "tf-default-subnet-2"
  }
}