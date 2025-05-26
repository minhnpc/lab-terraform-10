region           = "ap-southeast-1"
route_cidr_block = "0.0.0.0/0"


instance_attr = {
  dev = {
    ami      = "ami-02f7b163d79aae0cb"
    type     = "t2.micro"
    key_name = "aws-keypair"
  }
  prod = {
    ami      = "ami-0b8607d2721c94a77"
    type     = "t2.micro"
    key_name = "aws-keypair"

  }
}

user_data = {
  dev = [
    "#!/bin/bash",
    "sudo yum update",
    "sudo yum install httpd -y",
    "sudo systemctl enable httpd",
    "sudo systemctl start httpd",
    "echo '<h1>hello from apache</h1>' | sudo tee /var/www/html/index.html"
  ],
  prod = [
    "#!/bin/bash",
    "sudo apt update",
    "sudo apt install nginx -y",
    "sudo systemctl enable nginx",
    "sudo systemctl start nginx",
    "echo '<h1>hello from nginx</h1>' | sudo tee /var/www/html/index.html"
  ]

}


