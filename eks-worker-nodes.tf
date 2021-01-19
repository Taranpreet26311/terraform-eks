#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "demo-node" {
  name = "${var.cluster-name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "demo"
  instance_types   = var.node_class
  node_role_arn   = aws_iam_role.demo-node.arn
  subnet_ids      = aws_subnet.demo[*].id

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "helm_release" "consul" {
  name = "consul"
  namespace = var.namespace
  chart = "./helm/consul-helm/"
  values = [file("./helm/consul-helm/values.yaml")]

  set {
    name  = "client.enabled"
    value = "true"
  }

  set {
    name  = "connectInject.enabled"
    value = "true"
  } 

  set {
    name  = "client.grpc"
    value = "true"
  } 

  set {
    name  = "syncCatalog.enabled"
    value = "true"
  } 
  depends_on = [aws_eks_node_group.demo]
}

resource "helm_release" "flask-app" {
  name = "flask-app"
  namespace = var.namespace
  chart = "./helm/flask-redis/"
  values = [file("./helm/flask-redis/values.yaml")]
  depends_on = [aws_eks_node_group.demo]
  
  set {
    name  = "env.flask1.image"
    value = "taran26311/flaskapp"
  }

  set {
    name  = "env.flask1.image_tag"
    value = "latest"
  } 

  set {
    name  = "env.flask1.replicas"
    value = "1"
  } 

  set {
    name  = "env.flask2.image"
    value = "taran26311/flaskapp"
  }

  set {
    name  = "env.flask2.image_tag"
    value = "latest"
  } 

  set {
    name  = "env.flask2.replicas"
    value = "2"
  } 

  set {
    name  = "env.flask_port"
    value = "5000"
  } 

  set {
    name  = "env.redis.host"
    value = "redis"
  } 

  set {
    name  = "env.redis.port"
    value = "6379"
  } 
}



