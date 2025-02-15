
# main.tf
provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-s3bucket-9890" # Replace with a unique bucket name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Configure Terraform to use the S3 bucket for state storage
terraform {
  backend "s3" {
    bucket = "my-s3bucket-9890" # Replace with the bucket name above
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Create an EC2 instance
resource "aws_instance" "Terraform-EC2" {
  ami           = "ami-053a45fff0a704a47" # Replace with your desired AMI
  instance_type = "t2.medium"

  tags = {
    Name = "Terraform-EC2"
  }

  # Security group to allow SSH and HTTP access
  vpc_security_group_ids = [aws_security_group.example.id]

  # Key pair for SSH access
  key_name = "vm-key" # Replace with your key pair name

  # Use remote-exec to install dependencies
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install git -y",
      "sudo yum install maven -y",
      "sudo yum install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo yum install java-11-openjdk-devel -y",
      "git --version",
      "mvn --version",
      "docker --version",
      "java --version"
    ]

    connection {
      type        = "ssh"
      user        = "root" 
      private_key = file("/path/to/your/private/key.pem") # Replace with the path to your private key
      host        = self.public_ip
    }
  }
}

# Security group for the EC2 instance
resource "aws_security_group" "example" {
  name_prefix = "terraform-example-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output the public IP of the EC2 instance
output "public_ip" {
  value = aws_instance.example.public_ip
}
