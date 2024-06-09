

resource "aws_ecs_cluster" "terracluster" {
  name = "terracluster"
}

resource "aws_ecs_task_definition" "mytask_terra_definition" {
  family = "mytask"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"  # Required for Fargate
  cpu = 256
  memory = 512
  container_definitions = jsonencode([{
    name = "terra-container"
    image = "docker.io/jaya91/npm"
    cpu = 256
    memory = 512
    essential = true
    portMappings = [
      {
        containerPort = 3000
      }
    ]
  }])
}


resource "aws_ecs_service" "terra_service" {
  name = "terra_service"
  cluster = aws_ecs_cluster.terracluster.id
  task_definition = aws_ecs_task_definition.mytask_terra_definition.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.subnet1.id]
    security_groups = [aws_security_group.sg.id]
    assign_public_ip = true
  
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
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
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
output "ecs_cluster_id" {
  value = aws_ecs_cluster.terracluster.id
}

output "ecs_service_id" {
  value = aws_ecs_service.terra_service.id
}




