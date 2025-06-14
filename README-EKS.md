# EKS Demo with Full-Stack App / DevOps practices / Terraform

This is an **EKS (Kubernetes) version** of the original ECS demo, showcasing modern containerized application deployment using Amazon EKS with full CI/CD automation.

## 🏗️ Architecture Overview

This project demonstrates a complete DevOps pipeline using:

- **Amazon EKS** - Managed Kubernetes service for container orchestration
- **AWS Load Balancer Controller** - Kubernetes ingress using ALB
- **Horizontal Pod Autoscaler (HPA)** - Automatic scaling based on CPU/Memory
- **ECR** - Container image storage
- **CodePipeline** - CI/CD automation
- **CodeBuild** - Build and deployment to Kubernetes
- **GitHub** - Source code repository with automated triggers

## 🚀 What Gets Deployed

### AWS Resources Created:
- **EKS Cluster** with managed node groups
- **VPC** with public/private subnets across 2 AZs
- **ECR Repositories** for Docker images (client + server)
- **CodePipeline** with GitHub integration
- **CodeBuild Projects** with kubectl deployment
- **Application Load Balancers** (via AWS Load Balancer Controller)
- **DynamoDB Table** for application data
- **S3 Buckets** for artifacts and assets
- **IAM Roles** with IRSA (IAM Roles for Service Accounts)
- **SNS Topic** for notifications

### Kubernetes Resources Created:
- **Deployments** for client and server applications
- **Services** (ClusterIP) for internal communication
- **Ingress** resources for external access via ALB
- **HorizontalPodAutoscalers** for automatic scaling
- **ServiceAccounts** with IAM role bindings

## 📋 Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** v0.13+ installed
3. **kubectl** installed (for managing the cluster post-deployment)
4. **GitHub Personal Access Token** with repo permissions
5. **Fork this repository** to your GitHub account

## 🛠️ Setup Instructions

### Step 1: Configure AWS Credentials
```bash
# Add to ~/.aws/credentials
[your-profile-name]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

### Step 2: Deploy Remote State Backend (Recommended)
```bash
cd Infrastructure/state-backend/
terraform init
terraform apply -var aws_profile="your-profile" -var aws_region="us-west-2" -var environment_name="your-env"

# Note the outputs, then configure backend
cd ../
cp backend.tf.example backend.tf
# Edit backend.tf with the S3 bucket and DynamoDB table names
```

### Step 3: Deploy EKS Infrastructure
```bash
cd Infrastructure/

# Use the EKS configuration files
cp main-eks.tf main.tf
cp variables-eks.tf variables.tf
cp outputs-eks.tf outputs.tf

terraform init
terraform plan -var aws_profile="your-profile" \
               -var aws_region="us-west-2" \
               -var environment_name="your-unique-env-name" \
               -var github_token="your-github-token" \
               -var repository_name="your-forked-repo-name" \
               -var repository_owner="your-github-username"

terraform apply [same variables as above]
```

### Step 4: Configure kubectl Access
```bash
# Update kubeconfig to access your EKS cluster
aws eks update-kubeconfig --region us-west-2 --name your-unique-env-name

# Verify access
kubectl get nodes
kubectl get pods --all-namespaces
```

### Step 5: Install AWS Load Balancer Controller
```bash
# Apply the service account (this should be automated, but verify)
kubectl apply -f Infrastructure/Templates/k8s-serviceaccount.yaml

# Install AWS Load Balancer Controller via Helm (recommended)
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=your-unique-env-name \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Step 6: Post-Deployment Setup
1. **Add S3 Assets**: Upload 3 sample images to the created S3 assets bucket
2. **Populate DynamoDB**: Add sample items with structure:
   ```json
   {
     "id": {"N": "1"},
     "path": {"S": "https://your-bucket.s3.region.amazonaws.com/image.jpg"},
     "title": {"S": "Sample Title"}
   }
   ```
3. **Monitor Pipeline**: Check AWS CodePipeline console for automated deployment

### Step 7: Access Your Applications
```bash
# Get application URLs
kubectl get ingress

# Example output:
# NAME                    CLASS    HOSTS   ADDRESS                                    PORTS
# your-env-client-ingress   alb      *       k8s-default-yourenv-xxxxx.region.elb.amazonaws.com   80
# your-env-server-ingress   alb      *       k8s-default-yourenv-yyyyy.region.elb.amazonaws.com   80
```

## 🔧 Key Differences from ECS Version

| **Component** | **ECS Version** | **EKS Version** |
|---|---|---|
| **Orchestration** | ECS Fargate | EKS with EC2 nodes |
| **Service Discovery** | ECS Service | Kubernetes Service + Ingress |
| **Load Balancing** | Direct ALB integration | AWS Load Balancer Controller |
| **Scaling** | ECS Auto Scaling | Horizontal Pod Autoscaler |
| **Deployment** | CodeDeploy Blue/Green | kubectl rolling updates |
| **Service Accounts** | ECS Task Roles | IRSA (IAM Roles for Service Accounts) |
| **Networking** | ECS awsvpc mode | Kubernetes CNI |

## 🚀 CI/CD Pipeline

1. **Source**: GitHub webhook triggers on push to main branch
2. **Build**: Parallel CodeBuild projects for client and server
   - Build Docker images
   - Push to ECR
   - Apply Kubernetes manifests using kubectl
3. **Deploy**: Automatic deployment to EKS cluster
   - Rolling updates for zero downtime
   - Health checks via readiness/liveness probes

## 📊 Monitoring and Scaling

### Automatic Scaling
- **Cluster Autoscaler**: Automatically adds/removes nodes based on demand
- **HPA**: Scales pods based on CPU/Memory utilization (70% CPU, 80% Memory)
- **Resource Limits**: Proper CPU/Memory requests and limits

### Monitoring
```bash
# Monitor pod status
kubectl get pods

# Check HPA status
kubectl get hpa

# View pod logs
kubectl logs -f deployment/your-env-server

# Monitor ingress status
kubectl describe ingress your-env-server-ingress
```

## 🧪 Testing Autoscaling

Use the same artillery tests, but target the Kubernetes ingress endpoints:

```bash
# Update stress test files with ingress URLs
# Frontend layer:
artillery run client/src/tests/stresstests/stress_client.yml

# Backend layer:
artillery run server/src/tests/stresstests/stress_server.yml
```

## 🛠️ Troubleshooting

### Common Issues:

1. **AWS Load Balancer Controller not working**:
   ```bash
   kubectl logs -n kube-system deployment/aws-load-balancer-controller
   ```

2. **Pods not getting scheduled**:
   ```bash
   kubectl describe nodes
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

3. **Ingress not creating ALB**:
   ```bash
   kubectl describe ingress your-ingress-name
   ```

## 🧹 Cleanup

```bash
# Delete Kubernetes resources first
kubectl delete ingress --all
kubectl delete service --all
kubectl delete deployment --all

# Then destroy Terraform infrastructure
terraform destroy -var aws_profile="your-profile" \
                  -var aws_region="your-region" \
                  -var environment_name="your-env" \
                  -var github_token="your-personal-token" \
                  -var repository_name="your-github-repository" \
                  -var repository_owner="the-github-repository-owner"
```

## 🔒 Security Features

- **RBAC**: Kubernetes Role-Based Access Control
- **Network Policies**: Pod-to-pod communication control (can be added)
- **IRSA**: Secure AWS service access without long-lived credentials
- **Private Subnets**: Worker nodes in private subnets
- **Security Groups**: Fine-grained network access control

## 🚀 Advantages of EKS Version

1. **Kubernetes Native**: Access to full Kubernetes ecosystem
2. **Better Resource Utilization**: More efficient than Fargate for persistent workloads
3. **Advanced Scheduling**: Kubernetes scheduler with affinities, tolerations
4. **Extensibility**: Easy to add Kubernetes operators and custom resources
5. **Cost Optimization**: Better cost control with spot instances and cluster autoscaler
6. **Multi-tenancy**: Better isolation and resource quotas

## 📚 Next Steps

- Add **Istio** service mesh for advanced traffic management
- Implement **ArgoCD** for GitOps deployment
- Add **Prometheus + Grafana** for monitoring
- Set up **Kubernetes Network Policies** for security
- Configure **Cluster Autoscaler** for cost optimization
- Add **Spot Instance** support for further cost savings

This EKS version provides a more powerful and flexible foundation for production Kubernetes workloads while maintaining the same CI/CD automation and AWS integration benefits. 