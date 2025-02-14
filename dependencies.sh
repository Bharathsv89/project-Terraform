#!/bin/bash
sudo yum update -y
sudo yum install -y git maven docker java-1.8.0-openjdk
sudo systemctl start docker
sudo systemctl enable docker