provider "aws" {}
resource "aws_instance" "jenkins" {
  ami           = "ami-012142d0d2c50938c"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}


variable "Instance_AMI_ID" {}
variable "Instance_name" {}