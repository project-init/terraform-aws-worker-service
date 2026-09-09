# Project Init AWS Cognito

## Quick Start

1. `mise format`
2. `mise docs`

## Usage

Check our [Examples](examples) for full usage information.

### Workload IAM policies

Pass named IAM policy JSON documents through `iam_policies` to grant your
worker workload permissions. Add this argument to your existing worker module
block:

```hcl
iam_policies = {
  workload_access = data.aws_iam_policy_document.workload_access.json
}
```

Each map key becomes an inline policy name, and its value is the policy JSON
document. You can also pass policy JSON outputs from other modules.

The default is `{}`, which creates no additional inline policies. Policies
attach to the service IAM role, which this module currently uses as both the
ECS task role and execution role.

## Useful Docs

* [Code of Conduct](./CODE_OF_CONDUCT.md)
* [Contribution Guide](./CONTRIBUTING.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.81.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_appautoscaling_policy.ecs_policy_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_policy_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.ecs_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.service_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | List of capacity providers to use for distributing tasks. Should primarily be used when utilizing ec2 backed ecs. | <pre>set(object({<br/>    capacity_provider = string<br/>    base              = number<br/>    weight            = number<br/>  }))</pre> | `[]` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The cpu value to give to the ecs task. | `number` | `256` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired count of tasks to run. This is ignored after the first apply. | `number` | `0` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | The ARN of the ecs cluster to deploy the service on. | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | The name of the ecs cluster to deploy the service on. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment to deploy the worker service to. | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables to use for the service. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Whether to force a new deployment when updating the ecs service. | `bool` | `false` | no |
| <a name="input_iam_policies"></a> [iam\_policies](#input\_iam\_policies) | Map of inline policy names to IAM policy JSON documents to attach to the worker task role. | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | The docker image to use for the container. | `string` | n/a | yes |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum amount of the tasks to run. | `number` | `0` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The memory value to give to the ecs task. | `number` | `512` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | The minimum amount of the tasks to run. | `number` | `0` | no |
| <a name="input_ordered_placement_strategies"></a> [ordered\_placement\_strategies](#input\_ordered\_placement\_strategies) | List of ordered placement strategies to use for distributing tasks. Should primarily be used when utilizing ec2 backed ecs. | <pre>set(object({<br/>    type  = string<br/>    field = string<br/>  }))</pre> | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The secrets to use for the service. | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | IDs of the extra security groups you want the task to have access to. | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the service. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnets to deploy the service in to. | `set(string)` | n/a | yes |
| <a name="input_use_ec2"></a> [use\_ec2](#input\_use\_ec2) | Whether to deploy the service on an ec2 backed service or fargate. | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID being deployed to. | `string` | n/a | yes |
| <a name="input_worker_name"></a> [worker\_name](#input\_worker\_name) | The name of the worker. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group for the worker service |
| <a name="output_service_iam_role_arn"></a> [service\_iam\_role\_arn](#output\_service\_iam\_role\_arn) | The ARN of the IAM role for the worker service |
| <a name="output_service_iam_role_name"></a> [service\_iam\_role\_name](#output\_service\_iam\_role\_name) | The name of the IAM role for the worker service |
<!-- END_TF_DOCS -->
