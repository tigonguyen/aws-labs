output "albTargetGroup1ARN" {
  value = aws_alb_target_group.loadBalancerTG1.arn
}

output "albTargetGroup2ARN" {
  value = aws_alb_target_group.loadBalancerTG2.arn
}