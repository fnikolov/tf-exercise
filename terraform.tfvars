# Primary region
primary_region          = "us-east-1"
primary_vpc_cidr        = "10.0.0.0/16"
instance_type           = "t2.micro"
instance_count          = 1
ami                     = "ami-06b21ccaeff8cd686"
root_block_device = {
  volume_size           = 30
  volume_type           = "gp3"
}

# Secondary region
secondary_region            = "eu-west-1"
secondary_vpc_cidr          = "10.1.0.0/16"
instance_count_secondary    = 1
ami_secondary               = "ami-00385a401487aefa4"
instance_type_secondary     = "t2.micro"
root_block_device_secondary = {
  volume_size = 30
  volume_type = "gp3"
}

project_name              = "flutter-poc"
environment               = "demo"
primary_certificate_arn   = "arn:aws:acm:us-east-1:605134433422:certificate/31669afb-304a-4ed7-a5dd-5243a83181a2"
secondary_certificate_arn = "arn:aws:acm:eu-west-1:605134433422:certificate/22334214-d854-4493-b8f2-2dad89facd09"





