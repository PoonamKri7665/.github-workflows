resource "aws_ecs_cluster" "terracluster" {
  name = "terracluster"
}

resource "aws_ecs_task_definition" "mytask_terra_definition" {
  family                   = "task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"  # Required for Fargate
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([{
    name  = "terra"
    image = "docker.io/jaya91/npm"
    cpu   = 256
    memory = 512
    essential = true
    portMappings = [{
      containerPort = 3030
    }]
  }])
}

resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = aws_ecs_cluster.terracluster.id
  task_definition = aws_ecs_task_definition.mytask_terra_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0944e097a7bf89c0c"]
    security_groups = ["sg-06f9677f0d89140b9"]
    assign_public_ip = true
  }
}

# Check if the ECS Task Execution Role already exists
data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  count = length(data.aws_iam_role.ecsTaskExecutionRole.name) == 0 ? 1 : 0

  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  count = length(data.aws_iam_role.ecsTaskExecutionRole.name) == 0 ? 1 : 0

  role       = aws_iam_role.ecsTaskExecutionRole[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.terracluster.id
}

output "ecs_service_id" {
  value = aws_ecs_service.service.id
}
