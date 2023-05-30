# terraform-aws-ecs-sample-infra
## Description
- [x] Create a network with public & private subnets
- [x] Create a load balancer which redirects requests from port 80 to 443 and security groups
- [x] Create an AWS ECS Fargate cluster and run 2 tasks there using a standard Nginx image
- [ ] Create a Blue/Green deployment pipeline with Github Action

## Architecture diagram
![](./images/aws-ecs-with-terragrunt.jpeg)

## Usage
### Prerequisite
- An AWS programable account with corresponding permissions
- An ECR - Elastic Container Registry
- A service role already created that grants CodeDeploy access to Amazon ECS (create after run Terragrunt).
### Instruction
#### Prepare your Docker image
Authenticate your AWS client with enironment variable:
```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxx
export AWS_DEFAULT_REGION=us-west-2
```
Authenticate your Docker client to the Amazon ECR repository
```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
```
Use `docker images` to identify the local image to push, then push it:
```
docker tag nginx:latest public.ecr.aws/xxxxxxxx/nginx:v0.1.0
docker push public.ecr.aws/xxxxxxxx/nginx:v0.1.0
```
#### Deploy your Infrastruture with Terragrunt:
Create your environment settings in file `envVars.yaml`, for example:
```
env: "dev"
vpcCIDR: "10.0.0.0/16"
privateSubnets: 
  - "10.0.1.0/24"
  - "10.0.2.0/24"
publicSubnets: 
  - "10.0.3.0/24"
  - "10.0.4.0/24"
availabilityZones:
  - "ap-southeast-1a"
  - "ap-southeast-1b"
imageURI: "public.ecr.aws/k2u4r9u5/nginx:v0.1.0"
containerPort: 443
```
For deploy your entire infrastructure, in the terragrunt root directory, run:
```
terragrunt run-all apply
```
#### Blue/Green deployment preparing with CodeDeploy
1. Open the CodeDeploy console  and choose **Create application**.
2. In **Application name**, enter the name you want to use.
3. In Compute platform, choose `Amazon ECS`, then **Create Application**.
![](./images/codedeploy-app-create.png)
4. On your application page's Deployment groups tab, choose **Create deployment group**.
5. In **Deployment group name**, enter a name that describes the deployment group.
6. In **Service role**, choose a service role already created that grants CodeDeploy access to Amazon ECS.
7. In **Environment configuration**, choose your Amazon ECS cluster name and service name.
8. From **Load balancers**, choose the name of the load balancer that serves traffic to your Amazon ECS service.
9. From **Production listener port**, choose the port and protocol for the listener that serves production traﬃc to your Amazon ECS service.
10. From **Target group 1 name** and **Target group 2 name**, choose the target groups used to route traffic during your deployment. Make sure that these are the target groups you created for your load balancer.
11. Choose **Reroute traffic immediately** to determine how long after a successful deployment to reroute traffic to your updated Amazon ECS task.
12. Under **Original revision termination**, make it 0 - 0 - 0 for Days, Hours and Minutes. As we are testing, we can terminate original tasks immediately after rerouting traffic.
13. Choose **Create deployment group**.
14. Add Deploy Stage to you CodePipeline, remember choose `Amazon ECS (Blue/Green)` to your **Action Provider**.
