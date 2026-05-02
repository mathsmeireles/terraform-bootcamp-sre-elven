output "instance_ip" {
  description = "IP of EC2 Instance"
  value       = aws_instance.wordpress_instance.public_ip
}
