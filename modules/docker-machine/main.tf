data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.project_name}-ssh-key"
  public_key = file(var.ssh_public_key)
}

resource "aws_instance" "master" {
  ami               = data.aws_ami.amazon-linux-2.id
  availability_zone = "${var.region}a"
  instance_type     = var.instance_type
  key_name          = aws_key_pair.ssh.key_name
  security_groups   = [aws_security_group.ssh.name, aws_default_security_group.default.name]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = "true"
  }

  tags = merge(var.tags, { "Name" = "${var.project_name}" })

  volume_tags = merge(var.tags, { "Name" = "${var.project_name}-volume" })

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo chkconfig docker on",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose"
    ]
  }
}

