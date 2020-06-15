provider "aws" {
  region     = "ap-south-1"
  profile    = "mycloud2"
}

//about the instance

resource "aws_instance" "myin" {
  ami             = "ami-0447a12f28fddb066"
  instance_type   = "t2.micro"
  key_name        = "myterrakey"
  security_groups = [ "mysecurity1" ]

  tags = {
    Name = "linuxos2"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/user/Downloads/myterrakey.pem")
    host     = aws_instance.myin.public_ip
   }
   provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }
}

//print the output

output "myout1" {
  value = aws_instance.myin.public_ip
}

//create volume

resource "aws_ebs_volume" "example" {
  availability_zone = aws_instance.myin.availability_zone
  size              = 1

  tags = {
    Name = "myebs1"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.example.id}"
  instance_id = "${aws_instance.myin.id}"
}

//provisioner

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/user/Downloads/myterrakey.pem")
    host     = aws_instance.myin.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/vimallinuxworld13/multicloud.git /var/www/html/"
    ]
  }
}

resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.myin.public_ip}"
  	}
}






