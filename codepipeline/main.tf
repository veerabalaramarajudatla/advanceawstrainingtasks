terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region     = "eu-north-1"
  access_key = var.access_key
  secret_key = var.secret_key
}


data "aws_iam_role" "name" {
  name = "aws-codepipeline-service-role"
}

resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket = "codepipeline-artifact-tf-2205-us-east-1"
}

resource "aws_codepipeline" "codepipeline" {
  name       = "tf-test-pipeline"
  role_arn   = data.aws_iam_role.name.arn
  pipeline_type = "V2"
  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket = data.aws_s3_bucket.source.bucket
        S3ObjectKey          = "19022024.zip" // Empty string to indicate the root of the bucket
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }
  
  stage {
    name = "Manual-Approval"

    action {
      run_order = 1
      name             = "AWS-Admin-Approval"
      category         = "Approval"
      owner            = "AWS"
      provider         = "Manual"
      version          = "1"
      input_artifacts  = []
      output_artifacts = []

      configuration = {
        CustomData = "Please verify the terraform plan output on the Plan stage and only approve this step if you see expected changes!"
      }
    }
  }
  stage {
    name = "Deploy-Prelive"

    action {
      name            = "DeployECS-Prelive"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      run_order       = 1
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = var.ecs_cluster
        ServiceName = var.ecs_service
        FileName    = var.image_definitions_file
      }
    }
  }
}
##############################
#         CODE BUILD         #
##############################

data "aws_s3_bucket" "source" {
  bucket   = "bitbucket-repo"
}

data "aws_iam_role" "codebuildarn" {
  name = "codebuild-aws-codebuild-v1-service-role"
}
resource "aws_codebuild_project" "codebuild" {
  name          = "test-project-terraform"
  description   = "test_codebuild_project_using_terraform"
  build_timeout = 10
  service_role  = data.aws_iam_role.codebuildarn.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "eu-north-1"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "753863853239"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "code-pipeline-ecr"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }
  
  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}


