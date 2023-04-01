resource "aws_codebuild_project" "ProductServiceCodeBuild" {
    arn                    = "arn:aws:codebuild:us-east-1:385501908346:project/products-service-build"
    badge_enabled          = false
    build_timeout          = 60
    concurrent_build_limit = 0
    encryption_key         = "arn:aws:kms:us-east-1:385501908346:alias/aws/s3"
    id                     = "products-service-build"
    name                   = "products-service-build"
    project_visibility     = "PRIVATE"
    queued_timeout         = 480
    service_role           = "arn:aws:iam::385501908346:role/service-role/codebuild-products-service-build-service-role"
    source_version         = "refs/heads/master"
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
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode             = true
        type                        = "LINUX_CONTAINER"

        environment_variable {
            name  = "AWS_DEFAULT_REGION"
            type  = "PLAINTEXT"
            value = "us-east-1"
        }
        environment_variable {
            name  = "AWS_ACCOUNT_ID"
            type  = "PLAINTEXT"
            value = "385501908346"
        }
        environment_variable {
            name  = "IMAGE_REPO_NAME"
            type  = "PLAINTEXT"
            value = "products-service"
        }
        environment_variable {
            name  = "IMAGE_TAG"
            type  = "PLAINTEXT"
            value = "latest"
        }
    }

    logs_config {
        cloudwatch_logs {
            group_name  = "products-service-log-group"
            status      = "ENABLED"
            stream_name = "products-service-log-stream"
        }

        s3_logs {
            encryption_disabled = false
            status              = "DISABLED"
        }
    }

    source {
        git_clone_depth     = 1
        insecure_ssl        = false
        location            = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/products-service"
        report_build_status = false
        type                = "CODECOMMIT"

        git_submodules_config {
            fetch_submodules = false
        }
    }
}

# aws_codecommit_repository.productServiceCodeCommit:
resource "aws_codecommit_repository" "ProductServiceCodeCommit" {
    arn             = "arn:aws:codecommit:us-east-1:385501908346:products-service"
    clone_url_http  = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/products-service"
    clone_url_ssh   = "ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/products-service"
    id              = "products-service"
    repository_id   = "60aaae7e-1b6e-4830-a136-eb85172752fc"
    repository_name = "products-service"
    tags            = {}
    tags_all        = {}
}

# aws_codepipeline.productServiceCodePipeline:
resource "aws_codepipeline" "ProductServiceCodePipeline" {
    arn      = "arn:aws:codepipeline:us-east-1:385501908346:products-service-pipeline"
    id       = "products-service-pipeline"
    name     = "products-service-pipeline"
    role_arn = "arn:aws:iam::385501908346:role/service-role/AWSCodePipelineServiceRole-us-east-1-catpipeline"
    tags     = {}
    tags_all = {}

    artifact_store {
        location = "codepipeline-us-east-1-743172729228"
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            category         = "Source"
            configuration    = {
                "BranchName"           = "master"
                "OutputArtifactFormat" = "CODE_ZIP"
                "PollForSourceChanges" = "false"
                "RepositoryName"       = "products-service"
            }
            input_artifacts  = []
            name             = "Source"
            namespace        = "SourceVariables"
            output_artifacts = [
                "SourceArtifact",
            ]
            owner            = "AWS"
            provider         = "CodeCommit"
            region           = "us-east-1"
            run_order        = 1
            version          = "1"
        }
    }
    stage {
        name = "Build"

        action {
            category         = "Build"
            configuration    = {
                "ProjectName" = "products-service-build"
            }
            input_artifacts  = [
                "SourceArtifact",
            ]
            name             = "Build"
            namespace        = "BuildVariables"
            output_artifacts = [
                "BuildArtifact",
            ]
            owner            = "AWS"
            provider         = "CodeBuild"
            region           = "us-east-1"
            run_order        = 1
            version          = "1"
        }
    }
    stage {
        name = "Deploy"

        action {
            category         = "Deploy"
            configuration    = {
                "ClusterName" = "products-service-ecs-cluster"
                "FileName"    = "imagedefinitions.json"
                "ServiceName" = "products-ecs-service"
            }
            input_artifacts  = [
                "BuildArtifact",
            ]
            name             = "Deploy"
            namespace        = "DeployVariables"
            output_artifacts = []
            owner            = "AWS"
            provider         = "ECS"
            region           = "us-east-1"
            run_order        = 1
            version          = "1"
        }
    }
}
