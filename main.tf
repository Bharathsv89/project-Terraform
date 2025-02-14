provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

terraform {
  backend "s3" {
    bucket = "my-s3bucket001122" # Replace with your S3 bucket name
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "example" {
  ami           = "ami-053a45fff0a704a47" # Replace with your desired AMI ID
  instance_type = "t2.medium"

  tags = {
    Name = "Terraform-EC2-Instance"
  }

  # Use remote-exec to run the shell script after instance creation
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y git maven docker java-1.8.0-openjdk",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("vm-key") # Replace with your private key path
      host        = self.public_ip
    }
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
