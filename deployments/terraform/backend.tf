#terraform {
 #   backend "s3" {
   #     bucket = "jenkins-instance-east-1"
    #    key = "jenkins/us-east-1/class/dev/infrastructure.tfstate"
     #   region = "us-east-1"
    #}
#}

  
terraform {
    backend "s3" {
        bucket = "jenkins-instance-east-1"
        key = "jenkins/us-east-1/class/dev/infrastructure.tfstate"
        region = "us-east-1"
    }
}