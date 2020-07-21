provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "jenkins" {
  ami           = "ami-012142d0d2c50938c"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}