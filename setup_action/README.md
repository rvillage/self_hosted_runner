# self_hosted_runner/setup_action

This action run a Self-hosted Runner running on AWS CodeBuild.

## Usage

### Inputs

1. `personal-access-token` (required) : GitHub Personal access token
2. `project-name` (optional) : AWS CodeBuild Project Name, Defaults to SelfHostedRunner
3. `compute-type-override` (optional) : AWS CodeBuild Compute Type, Defaults to BUILD_GENERAL1_SMALL

### Outputs

1. `aws-build-id` : The AWS CodeBuild Build ID

### Example

```yaml
name: SelfHostedRunner Test
on: push

jobs:
  setup:
    runs-on: ubuntu-20.04
    steps:
      - uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1
      - uses: rvillage/self_hosted_runner/setup_action@v1-beta
        id: setup
        with:
          personal-access-token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
      - run: echo ${{ steps.setup.outputs.aws-build-id }}
```
