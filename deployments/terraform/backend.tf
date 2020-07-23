terraform {
    backend "s3" {
        bucket = "jenkins-instance-east"
        key = "jenkins/us-east-1/class/dev/infrastructure.tfstate"
        region = "us-east-1"
    }
}