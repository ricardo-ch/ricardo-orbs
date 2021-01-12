[Home](../../README.md)

# Jobs

Easily author and add [Parameterized Jobs](https://circleci.com/docs/2.0/reusing-config/#authoring-parameterized-jobs) to the `src/jobs` directory.

Each _YAML_ file within this directory will be treated as an orb job, with a name which matches its filename.

Jobs may invoke orb commands and other steps to fully automate tasks with minimal user configuration.

### Quality Gate Job

**Name**: quality_gate_job

**Parameters**:

- **resource_class,** [circleci resource_class](https://circleci.com/docs/2.0/configuration-reference/#resource_class), default is *medium.*
- **executor**, [circleci executor](https://circleci.com/docs/2.0/configuration-reference/#docker--machine--macos--windows-executor)
- **cache_name** Not required. If not specified cache will not be used/created.
- **cache_path** Not required. If not specified cache will not be created.
- **quality_checks** is a list of steps to run. By default they are:
    - make install
    - make build
    - make test

For applications that already have defined *Makefile* and above defined targets usage is quite simple. Otherwise there are two paths to add custom steps to configuration or to add Makefile(recommended).

**Examples**

In this example:

- user defined executor is used
- custom name
- custom steps

```yaml
...
jobs:
...
- ric-orb/quality_gate_job:
    executor: cypress-with-gcloud
    name: integration-test
    context: dev
    quality_checks:
      - ric-orb/auth_gke
      - run:
          name: Install newman
          command: npm install newman --global
      - ric-orb/gke_port_forward:
          context: $GKE_CLUSTER_NAME
          port: 8080
          namespace: payment
          target: svc/mysvc-api-svc
      - run:
          name: Run integration tests
          command: make test-integration
    requires:
      - deploy_dev
...
```

In this example is default setting, only required is added:

```yaml
...
jobs:
...
  - ric-orb/quality_gate_job:
      executor: go
      context: dev
...
```

Cache example:

```yaml
...
jobs:
...
  - ric-orb/quality_gate_job:
      executor: go
      context: dev
      cache_name: dependency-cache-{{ checksum "go.sum" }}
      cache_path: "$GOPATH/pkg/mod"
...
```

### Build And Push Docker Image Job

**Name**: build_push_image

**Parameters**:

- **isopod_version** isopod version in executor. Not required. Default is **latest**
- **docker_hub_username** username for public docker registry(Docker Hub), default is value of context variable DOCKER_HUB_USERNAME
- **docker_hub_password** password for public docker registry(Docker Hub), default is value of context variable DOCKER_HUB_PASSWORD
- **private_hub_username** username for private docker registry, default is value of context variable DOCKER_JFROG_USERNAME
- **private_hub_password** password for private docker registry, default is value of context variable DOCKER_JFROG_PASSWORD
- **private_hub_url** url for private docker registry, default is value of context variable DOCKER_JFROG_REGISTRY_URL
- **cache_name** Not required. If not specified cache will not be used/created
- **maven_credentials** environment/context variable which holds base64 encoded content for .m2/settings.xml file. Default is ARTIFACTORY_MAVEN_CREDENTIALS which already defined in our contexts
- **npm_credentials** environment/context variable which holds base64 encoded content for .npmrc file. Default is NPM_RC which already defined in our contexts
- **docker_layer_cashing**, for enabling [docker layer caching](https://circleci.com/docs/2.0/docker-layer-caching/), default is *false.* Add to the build costs(money) but docker image building can be faster.
- **docker_version**, [see docs](https://circleci.com/docs/2.0/building-docker-images/#docker-version). Default is 19.03.13
- **prebuild_steps,** the list of steps that are executed to prepare building image/application. Default is no steps.
- **build_steps,** the list of steps to build application/image. Default is `isopod build`
- **postbuild_steps** the list of steps that are executed after building image/application
- **lang,**  specify type of application to be built. Default is go.

This job builds docker image and pushes the image to the private docker registry. Uses *isopod *****executor from orb.

**Examples**

This example:

- custom pre-build steps
- enabling docker_layer_cashing
- lang is node

```yaml
...
jobs:
...
  - ric-orb/build_push_image:
      lang: node
      prebuild_steps:
        - run:
            name: Copy env variable to .env file (to be used in Docker image by Sentry Webpack plugin)
            command: printenv > .env.sentry
      docker_layer_cashing: true
      name: docker
      context: dev
      requires:
        - request_branch_deployment_to_dev
...
```

All default except lang:

```yaml
...
jobs:
...
  - ric-orb/build_push_image:
      lang: java
      name: build_image
      context: dev
      requires:
        - request_branch_deployment_to_dev
        - quality-gate
```

Custom properties:

```yaml
...
jobs:
...
  - ric-orb/build_push_image:
      isopod_version: 0.16.1
      private_hub_username: $PDOCKER_USERNAME
      private_hub_password: $PDOCKER_PASSWORD
      docker_hub_username: $MY_DOCKER_HUB_USERNAME
      docker_hub_password: $MY_DOCKER_HUB_PASSWORD
      private_hub_url: $PDOCKER_REGISTRY_URL
      cache_name: dependency-cache-{{ checksum "go.sum" }}
      context: dev
      requires:
        - request_branch_deployment_to_dev
        - quality-gate
...
```

### Deploy Job

**Name**: deploy_job

**Parameters**:

- **isopod_version** isopod version in executor. Not required. Default is **latest**
- **private_hub_username** username for private docker registry, default is value of context variable DOCKER_JFROG_USERNAME
- **private_hub_password** password for private docker registry, default is value of context variable DOCKER_JFROG_PASSWORD
- **env** environment for which deployment is executed. Can be *dev* or *prod.* Default is dev.
- **predeploy_steps** steps that are executed to prepare deployment. Default is no steps.
- **deploy_steps** steps to be executed during deployment. Default is *ric-orb/deploy*
- **default_deploy** flag to run default deployment or custom. Default is true.
- **postdeploy_steps** steps that are executed after deployment. Default is no steps.
- **slack_notify_success** flag to send slack message if job is successful. Default is false.
- **slack_ok_webhook** the slack webhook used to send slack message on success. Default is value from context variable SLACK_WEBHOOK.
- **slack_ok_branches** comma separated list of branches for which successful slack message will be sent. Default is *master*.
- **slack_notify_failure** flag to send slack message when job fails. Default is false.
- **slack_fail_webhook** the slack webhook used to send slack message on failure. Default is value from context variable SLACK_WEBHOOK
- **slack_fail_branches** comma separated list of branches for which failure slack message will be sent. Default is *master*

This job executes deployment on GKE. It sends slack message on success/failure if enabled.

Examples:

Deployment to prod with specific isopod version.

```yaml
...
jobs:
...
  - ric-orb/deploy_job:
      name: prod
      isopod_version: 0.16.1
      private_hub_username: $PDOCKER_USERNAME
      private_hub_password: $PDOCKER_PASSWORD
      env: prod
      context: prod
      requires:
          - integration-test
```

Deployment with slack notifications.

```yaml
...
jobs:
...
  - ric-orb/deploy_job:
      name: prod
      env: prod
      context: prod
      requires:
        - deploy_dev
      slack_notify_success: true
      slack_notify_fail: true
...
```

Slack failure on team channel:

```yaml
...
jobs:
...
  - ric-orb/deploy_job:
      name: prod
      env: prod
      context: prod
      requires:
        - deploy_dev
      slack_notify_fail: true
      slack_fail_webhook: http://...ddd.d.
...
```

Custom steps.

```yaml
...
jobs:
...
  - ric-orb/deploy_job:
      default_deploy: false
      env: dev
      context: dev
      name: dev_deploy
      predeploy_steps:
        - ric-orb/auth_gke
        - run:
            name: Removing HPA during deployment
            command: kubectl delete  hpa -n myapp_service myapp_service || true
      deploy_steps:
        - run:
            name: Generating all Kubernetes resources
            command: isopod deploy --environment dev --dry-run
      postdeploy_steps:
        - run:
            name: Applying all resources except HPA
            command: |
              K_PATH=/tmp/$(ls /tmp/ | grep -e "-k8s-m")
              for r in $(ls $K_PATH/ | grep -v autoscaler); do kubectl apply -f $K_PATH/$r; done
        - run:
            name: Wait for the deployment to finish for max 5min
            command: kubectl rollout status deployment myapp_service -n myapp_service --timeout=300s || true
        - run:
            name: Applying HPA resources
            command: |
              K_PATH=/tmp/$(ls /tmp/ | grep -e "-k8s-m")
              kubectl apply -f $K_PATH/$(ls $K_PATH | grep autoscaler)
      requires:
        - docker
```

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How To Author Commands](https://circleci.com/docs/2.0/reusing-config/#authoring-parameterized-jobs)
 - [Node Orb "test" Job](https://github.com/CircleCI-Public/node-orb/blob/master/src/jobs/test.yml)