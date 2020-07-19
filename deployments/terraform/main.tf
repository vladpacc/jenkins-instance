provider "aws" {
  region = "eu-west-2"
}
resource "aws_instance" "jenkins" {
  ami           = "ami-04a9da8453b8d2605"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins"
  }
}