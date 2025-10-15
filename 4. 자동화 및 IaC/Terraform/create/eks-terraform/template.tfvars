#### AWS ####
vpc_id = "vpc-0380a7c010d33693e"
subnet_ids = ["subnet-0a2e713ff638010d6", "subnet-08eb30b7c969a7c40"]

#### EKS ####
eks_name = "sandbox-cluster"
kubernetes_version = "1.32"
eks_principal_arn = "arn:aws:iam::010438509994:role/sandbox-eks-iam-role" #접속 role / kubeconfig에 이것 셋팅

#### IAM ####

cluster_security_group_id = "sg-09e1d38c3f4d4eb76"
cluster_additional_security_group_ids = ["sg-0ee42a3bc09b124bd"]
cluster_ip_family = "ipv4"
cluster_service_ipv4_cidr = "172.20.0.0/16"
cluster_auth_type = "API_AND_CONFIG_MAP"
enable_cluster_creator_admin_permittions = true
enable_cluster_irsa = true
cluster_upgrade_policy = "STANDARD" #STANDARD EXTENDED
cluster_encryption_kms_arn = "arn:aws:kms:ap-northeast-2:573825764025:key/47816521-e68f-4464-aab0-126b0499e3a5"
cluster_encryption_resources = ["secrets"]
eks_node_groups = {
  graviton_small = {
    name = "nodegroup-arm"
    min_size     = 2
    max_size     = 2
    desired_size = 2
    launch_template_name   = "sandbox-eks-graviton-lc"
    ami_type               = "AL2023_ARM_64_STANDARD"
    instance_type          = "t4g.large"
    iam_role_arn = "arn:aws:iam::010438509994:role/sandbox-eks-node-iam-role" #노드권한
    key_name = "sandbox-eks-node-ec2-kp"
    create_iam_role = false
  }
}