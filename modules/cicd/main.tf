resource "aws_codebuild_project" "ProductServiceCodeBuild" {
    badge_enabled          = false
    build_timeout          = 60
    concurrent_build_limit = 1
    name                   = "product-service-build"
    project_visibility     = "PRIVATE"
    queued_timeout         = 480
    service_role           = aws_iam_role.CodeBuildRole.arn
    source_version         = "refs/heads/main"
    tags                   = {}
    tags_all               = {}

    artifacts {
        encryption_disabled    = false
        override_artifact_name = false
        type                   = "NO_ARTIFACTS"
    }

    cache {
        modes = []
        type  = "NO_CACHE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
        privileged_mode             = true
        type                        = "LINUX_CONTAINER"

        environment_variable {
            name  = "DOCKER_IMAGE_NAME"
            type  = "PLAINTEXT"
            value = var.docker_image_name
        }

        environment_variable {
            name  = "DOCKER_IMAGE_TAG"
            type  = "PLAINTEXT"
            value = "latest"
        }

        environment_variable {
            name  = "DOCKER_USER_NAME"
            type  = "PLAINTEXT"
            value = var.docker_user_name
        }

        environment_variable {
            name  = "AWS_ACCOUNT_ID"
            type  = "PLAINTEXT"
            value = var.aws_account_id
        }
    }

    logs_config {
        cloudwatch_logs {
            group_name  = "product-service-code-build-log-group"
            status      = "ENABLED"
        }
    }

    source {
        git_clone_depth     = 1
        insecure_ssl        = false
        location            = var.github_repo_url
        report_build_status = false
        type                = "GITHUB"

        git_submodules_config {
            fetch_submodules = true
        }
    }
}
//--------------------------------------------------------
resource "aws_codepipeline" "ProductServiceCodePipeline" {
    name = "product-service-pipeline"
    role_arn = aws_iam_role.CodePipelineRole.arn
    artifact_store {
        location = var.s3_bucket_code_pipeline_artifacts_name
        type = "S3"
    }
    stage {
        name = "Source"
        action {
            name = "Source"
            category = "Source"
            owner = "AWS"
            configuration = {
                BranchName = "main"
                ConnectionArn = var.github_connection_arn
                DetectChanges = "true"
                FullRepositoryId = regex("github.com/(.*)\\.git$", var.github_repo_url)[0]
                OutputArtifactFormat = "CODE_ZIP"
            }
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = [
                "SourceArtifact"
            ]
            run_order = 1
        }
    }
    stage {
        name = "Build"
        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            configuration = {
                ProjectName = aws_codebuild_project.ProductServiceCodeBuild.name
            }
            input_artifacts = [
                "SourceArtifact"
            ]
            provider = "CodeBuild"
            version = "1"
            output_artifacts = [
                "BuildArtifact"
            ]
            run_order = 1
        }
    }
    stage {
        name = "Deploy"
        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            configuration = {
                ClusterName = var.ecs_cluster_name
                FileName = "imagedefinitions.json"
                ServiceName = var.ecs_service_name
            }
            input_artifacts = [
                "BuildArtifact"
            ]
            provider = "ECS"
            version = "1"
            run_order = 1
        }
    }
}
//--------------------------------------------------------
resource "aws_iam_role" "CodePipelineRole" {
  name = "CodePipelineRole"

  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "codepipeline.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_policy" "CodePipelinePolicy" {
  name = "CodePipelinePolicy"
  policy = file("modules/cicd/CodePipelinePolicy.json")
}

resource "aws_iam_role_policy_attachment" "CodePipelinePolicyAttachment" {
  role       = aws_iam_role.CodePipelineRole.name
  policy_arn = aws_iam_policy.CodePipelinePolicy.arn
}
//--------------------------------------------------------
resource "aws_iam_role" "CodeBuildRole" {
  name = "CodeBuildRole"

  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "codebuild.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_policy" "CodeBuildPolicy" {
  name = "CodeBuildPolicy"
  policy = file("modules/cicd/CodeBuildPolicy.json")
}

resource "aws_iam_role_policy_attachment" "CodeBuildPolicyAttachment" {
  role       = aws_iam_role.CodeBuildRole.name
  policy_arn = aws_iam_policy.CodeBuildPolicy.arn
}