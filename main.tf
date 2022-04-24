provider "aws" {
				region = "us-east-1"
}

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