resource "aws_launch_template" "web" {

  image_id = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

}