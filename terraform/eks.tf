# 1. EKS Cluster Control Plane
resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.29" # Pinning K8s version for stability

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true # Nodes talk to Master internally
    endpoint_public_access  = true # You talk to Master from home (secured via IAM)
  }

  # Enable Control Plane Logging (Critical for Security Audits)
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure IAM policies exist before creating the cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = {
    Name = "${var.environment}-control-plane"
  }
}

# 2. EKS Node Group (The Worker Machines)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id # FORCE nodes into Private Subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Use Amazon Linux 2 optimized for EKS
  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"] # Cost-effective for portfolio

  # Ensure IAM policies exist before creating nodes
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only,
  ]

  tags = {
    Name = "${var.environment}-worker-node"
  }
}
