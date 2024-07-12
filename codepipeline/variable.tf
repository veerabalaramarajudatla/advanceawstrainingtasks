variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "codepipeline_name" {
  default = "tf-test-pipeline"
}

variable "ecs_cluster" {
  default = "aws-codebuild-cluster"
}

variable "ecs_service" {
  default = "ecs-codedeploy-service"
}

variable "image_definitions_file" {
  default = "imagedefinitions.json"
}