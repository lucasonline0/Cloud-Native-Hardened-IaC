# 1. EKS Cluster Security Group (Control Plane)
# Controls traffic to/from the Kubernetes API Server
resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-eks-cluster-sg"
  }
}

# Allow outbound traffic to anywhere (Required for EKS to manage AWS resources)
resource "aws_security_group_rule" "cluster_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
}

# 2. EKS Worker Nodes Security Group (Data Plane)
# Controls traffic between nodes and from the Control Plane
resource "aws_security_group" "eks_nodes" {
  name        = "${var.environment}-eks-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name                                           = "${var.environment}-eks-node-sg"
    "kubernetes.io/cluster/${var.environment}-app" = "owned"
  }
}

# Node-to-Node Communication (Required for Pod Networking)
resource "aws_security_group_rule" "nodes_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1" # All protocols
  description              = "Allow nodes to communicate with each other"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
}

# Allow Control Plane to communicate with Nodes (Kubelet API, logs, exec)
resource "aws_security_group_rule" "cluster_to_node" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  description              = "Allow Control Plane to talk to Worker Nodes"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
}

# Allow Nodes to communicate with Control Plane (API Server)
resource "aws_security_group_rule" "node_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  description              = "Allow Worker Nodes to talk to API Server"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
}

# Nodes Outbound (Download container images, patches)
resource "aws_security_group_rule" "node_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}
