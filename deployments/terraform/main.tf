provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "jenkins" {
  ami           = "ami-0b841c6a6460dd257"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}