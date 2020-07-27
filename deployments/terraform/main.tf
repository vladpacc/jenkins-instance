provider "aws" {}
resource "aws_instance" "jenkins" {
  ami           = "var.instance_ami_id"
  instance_type = "t2.micro"
  tags = {
    Name = "var.instance_name"
  }
}


variable "instance_ami_id" {}
variable "instance_name" {}