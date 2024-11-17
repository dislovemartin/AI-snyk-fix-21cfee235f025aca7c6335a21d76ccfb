output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

# ... other outputs as needed 