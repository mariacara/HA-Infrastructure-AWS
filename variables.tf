output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.loadbalancer.dns_name
}

variable "ami" {
  description = "The image id for the created wordpress ec2 template"
  default     = "ami-056a1ccefc98f46e1"
}

variable "instance_type" {
  description = "The instance type for the EC2"
  default     = "t2.micro"
}

variable "sg" {
  description = "The security group created for the webservers using wordpress"
  default     = "sg-04d9b26729e7a29fd"
}

variable "key" {
  description = "The EC2 key pair name"
  default     = "mc-skills"
}

