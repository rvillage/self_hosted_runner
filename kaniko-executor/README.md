# kaniko-executor

## Inputs

1. `images` (required) : Build image names ('name:tag,name:tag' format)
2. `cache-repo` (required) : Pushing to docker repository for layer cache
3. `target` (optional) : Docker build target directory, Defaults to $PWD
4. `dockerfile` (optional) : Dockerfile name, Defaults to Dockerfile

## Outputs

Return none.

## Example

```yaml
steps:
  - uses: actions/checkout@v2
    with:
      ref: ${{ github.base_ref }}
  - uses: rvillage/self_hosted_runner/kaniko-executor@v1-beta
    with:
      images: image:tag
      cache-repo: docker-repository-for-cache
```
