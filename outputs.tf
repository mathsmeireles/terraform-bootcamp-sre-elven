output "instance_ip" {
  description = "IP of EC2 Instamce"
  value       = aws_instance.wordpress_instance.public_ip
}
