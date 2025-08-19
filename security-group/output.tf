output "security_group_ids" {
  description = "The IDs of the security groups created"
  value       = aws_security_group.sg.*.id

}
