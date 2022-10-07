[Home](../../README.md)

# Jobs

Easily author and add [Parameterized Jobs](https://circleci.com/docs/2.0/reusing-config/#authoring-parameterized-jobs) to the [src/jobs directory](.).

Each _YAML_ file within this directory will be treated as an orb job, with a name which matches its filename.

Jobs may invoke orb commands and other steps to fully automate tasks with minimal user configuration.

### Quality Gate Job

**Name**: quality_gate_job

Generic quality gate job

**Parameters**:
- **resource_class**: [circleci resource_class](https://circleci.com/docs/2.0/configuration-reference/#resource_class), default is *medium.*
- **executor**: [circleci executor](https://circleci.com/docs/2.0/configuration-reference/#docker--machine--macos--windows-executor)
- **cache_name**: Not required. If not specified cache will not be used/created.
- **cache_path**: Not required. If not specified cache will not be created.
- **quality_checks**: is a list of steps to run. The default is: `install_build_test`

For applications that already have defined *Makefile* and above defined targets usage is quite simple. Otherwise there are two paths to add custom steps to configuration or to add Makefile(recommended).

**Examples**

In this example you configure:
- user defined executor
- custom name
- custom steps
```yaml
# ...
jobs:
  # ...
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
```

In this example you configure default settings, and only required parameters are added:
```yaml
# ...
jobs:
  # ...
  - ric-orb/quality_gate_job:
      executor: go
      context: dev
```

Cache example:
```yaml
# ...
jobs:
  # ...
  - ric-orb/quality_gate_job:
      executor: go
      context: dev
      cache_name: dependency-cache-{{ checksum "go.sum" }}
      cache_path: "$GOPATH/pkg/mod"
```

### Docker build & push (Docker Image) Job

**Name**: docker_build_push

**Parameters**:
- **image_name**: The Docker image name (without the path, e.g. search-solr)
- **path**: Path to directory containing dockerfile (also working directory). Default is *"."*
- **docker_hub_username**: Docker hub credentials. Default is context variable *$DOCKER_HUB_USERNAME*
- **docker_hub_password**: Docker hub credentials. Default is context variable *$DOCKER_HUB_PASSWORD*
- **private_hub_url**: JFrog url. Default is *$DOCKER_JFROG_REGISTRY_URL*
- **private_hub_username**: JFrog credentials. Default is *$DOCKER_JFROG_USERNAME*
- **private_hub_password**: JFrog credentials. Default is *$DOCKER_JFROG_PASSWORD*
- **docker_version**: Default is *19.03.13*
- **docker_layer_caching**: To enable docker layer caching. Default is *true*

This job builds and pushes Docker image to private Docker hub. It uses docker for building and pushing.

**Examples**

Minimal
```yaml
#...
jobs:
  # ...
  - ric-orb/docker_build_push:
      image_name: my_image
#...
```

For a specific (maven) module:
```yaml
#...
jobs:
  # ...
  - ric-orb/docker_build_push:
      image_name: my_image
      path: my_maven_module
#...
```

### Isopod build & push Docker Image Job

**Name**: build_push_image
(TODO: should be called isopod_build_push, but that would be a breaking change)

**Parameters**:
- **path**: Path to directory containing isopod.yml file. NOTE: this directory will be the working directory for isopod (i.e. dockerfile is also expected there, and should be executable directly from that directory). Default is `.`
- **isopod_config**: Name of the isopod config file. Default is *isopod.yml*
- **isopod_version**: isopod version in executor. Not required. Default is *latest*
- **docker_hub_username**: username for public docker registry(Docker Hub), default is value of context variable *$DOCKER_HUB_USERNAME*
- **docker_hub_password**: password for public docker registry(Docker Hub), default is value of context variable *$DOCKER_HUB_PASSWORD*
- **private_hub_username**: username for private docker registry, default is value of context variable *$DOCKER_JFROG_USERNAME*
- **private_hub_password**: password for private docker registry, default is value of context variable *$DOCKER_JFROG_PASSWORD*
- **private_hub_url**: url for private docker registry, default is value of context variable *$DOCKER_JFROG_REGISTRY_URL*
- **cache_name**: Not required. If not specified cache will not be used/created
- **maven_credentials**: environment/context variable name (just the name, not the actual variable!) which holds base64 encoded content for .m2/settings.xml file. Default is *ARTIFACTORY_MAVEN_CREDENTIALS* which already defined in our contexts
- **npm_credentials**: environment/context variable name (just the name, not the actual variable!) which holds base64 encoded content for .npmrc file. Default is *NPM_RC* which already defined in our contexts
- **docker_layer_caching**: for enabling [docker layer caching](https://circleci.com/docs/2.0/docker-layer-caching/). Default is *true*
- **docker_version**: [see docs](https://circleci.com/docs/2.0/building-docker-images/#docker-version). Default is *19.03.13*
- **prebuild_steps**: the list of steps that are executed to prepare building image/application. Default is none
- **postbuild_steps**: the list of steps that are executed after building image/application. Default is none

This job builds docker image and pushes the image to the private docker registry. Uses *isopod *****executor from orb. Attaches root workspace to access existing build outputs.

**Examples**

Example with:
- custom pre-build steps
- disabling docker_layer_caching
```yaml
# ...
jobs:
  # ...
  - ric-orb/build_push_image:
      name: docker
      prebuild_steps:
        - run:
            name: Copy env variable to .env file (to be used in Docker image by Sentry Webpack plugin)
            command: printenv > .env.sentry
      docker_layer_caching: false
      context: dev
      requires:
        - maven_build_test
```

Example with all default:
```yaml
# ...
jobs:
  # ...
  - ric-orb/build_push_image:
      context: dev
      requires:
        - quality-gate
```

Example with custom properties:
```yaml
# ...
jobs:
  # ...
  - ric-orb/build_push_image:
      isopod_version: "0.29.6"
      docker_version: "19.03.13"
      isopod_config: isopod.yaml
      private_hub_username: ${PDOCKER_USERNAME}
      private_hub_password: ${PDOCKER_PASSWORD}
      docker_hub_username: ${MY_DOCKER_HUB_USERNAME}
      docker_hub_password: ${MY_DOCKER_HUB_PASSWORD}
      private_hub_url: ${PDOCKER_REGISTRY_URL}
      cache_name: dependency-cache-{{ checksum "go.sum" }}
      context: dev
      requires:
        - maven_build_test
```

Example for building docker image from java build outputs (as saved to workspace by maven_build_test job) for a specific app from a monorepo:
```yaml
# ...
jobs:
  # ...
  - ric-orb/build_push_image:
      context: dev
      path: "myapp"
      docker_version: "19.03.13"
      isopod_version: "0.29.6"
      requires:
        - maven_build_test
```

### Isodpod deploy Job

**Name**: deploy_job
(TODO: should be called isopod_deploy, but that would be a breaking change)

**Parameters**:
- **path**: Path to directory containing isopod.yml file. Default is "*.*"
- **isopod_config**: Name of the isopod config file. Default is *isopod.yml*
- **isopod_version**: isopod version in executor. Not required. Default is **latest**
- **private_hub_username**: username for private docker registry. Default is value of context variable ${DOCKER_JFROG_USERNAME}
- **private_hub_password**: password for private docker registry. Default is value of context variable ${DOCKER_JFROG_PASSWORD}
- **env**: environment for which deployment is executed. Values: *prod*, *dev*. Default is *dev*
- **predeploy_steps**: steps that are executed to prepare deployment. Default is none
- **postdeploy_steps**: steps that are executed after deployment. Default is none
- **slack_notify_success**: flag to send slack message if job is successful. Default is false
- **slack_ok_webhook**: the slack webhook used to send slack message on success. Default is value from context variable $SLACK_WEBHOOK
- **slack_ok_branches**: comma separated list of branches for which successful slack message will be sent. Default is *master*
- **slack_notify_failure**: flag to send slack message when job fails. Default is false
- **slack_fail_webhook**: the slack webhook used to send slack message on failure. Default is value from context variable $SLACK_WEBHOOK
- **slack_fail_branches**: comma separated list of branches for which failure slack message will be sent. Default is *master*
- **work_dir**: working directory for default deployment (with the isopod). This should be relative to the job working directory. Default is `.`

This job executes deployment on GKE.
It can send Slack message on success/failure.

Examples:

Deployment to prod with specific isopod version:
```yaml
# ...
jobs:
  # ...
  - ric-orb/deploy_job:
      isopod_version: 0.29.6
      private_hub_username: $PDOCKER_USERNAME
      private_hub_password: $PDOCKER_PASSWORD
      env: prod
      context: prod
      requires:
          - integration-test
```

Deployment with Slack notifications:
```yaml
# ...
jobs:
  # ...
  - ric-orb/deploy_job:
      env: prod
      context: prod
      requires:
        - deploy_dev
      slack_notify_success: true
      slack_notify_failure: true
```

Slack failure on team channel:
```yaml
# ...
jobs:
  # ...
  - ric-orb/deploy_job:
      env: prod
      context: prod
      requires:
        - deploy_dev
      slack_notify_failure: true
      slack_fail_webhook: http://...ddd.d.
```

Custom steps:
```yaml
# ...
jobs:
  # ...
  - ric-orb/deploy_job:
      env: dev
      context: dev
      predeploy_steps:
        - run:
            command: echo hello world
      postdeploy_steps:
        - run:
            command: echo adieu world
      requires:
        - docker
```

Deploys java image for a specific app with a specific isopod config file from a monorepo:
```yaml
# ...
jobs:
  # ...
  - ric-orb/deploy_job:
      context: dev
      path: "myapp"
      isopod_config: "isopod.yml"
      isopod_version: "0.29.6"
      env: "dev"
      requires:
        - build_push_image
```

### Push build to bucket Job

**Name**: push_build_to_bucket_job

**Parameters**:
- **isopod_version**: isopod version in executor. Not required. Default is **latest**
- **private_hub_username**: username for private docker registry, default is value of context variable DOCKER_JFROG_USERNAME
- **private_hub_password**: password for private docker registry, default is value of context variable DOCKER_JFROG_PASSWORD
- **bucket_name**: name of the bucket where assets will be pushed, default is value of context variable GCLOUD_WEB_ASSETS_BUCKET_NAME
- **bucket_path**: bucket's path where assets will be pushed, default is /static-assets
- **app_name**: this is a folder name for application's assets, the convention is to use a github repo name
- **source**: path to source of assets

**Examples**

All default

This will push static assets from `./build/assets` into  production bucket `ricardo-web-assets/static-assets/my-ricardo-spa` using gsutil rsync. the latest isopod image will be used as executor.

```yaml
# ...
jobs:
  # ...
  - ric-orb/push_build_to_bucket_job:
      context: prod
      source: ./build/assets
      app_name: my-ricardo-spa
```

Custom isopod version and custom bucket 

This will push static assets from `./build/assets` into  production bucket `custom-bucket/custom/path/my-ricardo-spa`, the isopod v0.20.4 image will be used as executor.

```yaml
# ...
jobs:
  # ...
  - ric-orb/push_build_to_bucket_job:
      context: prod
      source: ./build/assets
      app_name: my-ricardo-spa
      isopod_version: 0.20.4
      bucket_name: custom-bucket
      bucket_path: /custom/path
```

### Maven build and test job (for Java applications)

**Name**: maven_build_test

**Parameters**:
- **path**: Path of maven module for the app, or "." for single-app-repo. Default: "*.*"
- **cache_key_prefix**: Prefix for the maven artifacts cache-key (used in combination with checksum of *pom.xml*). No caching if blank. Default: *blank* 
- **executor**: Executor for the build. Values: *ric-orb/maven_docker*  (default; more lightweight), *ric-orb/maven_vm* (required by builds leveraging testcontainers and therefore depending on docker) or your custom executor

**Examples**

Builds java sources using a docker builder
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_build_test:
      context: dev
      cache_key_prefix: "myrepo"
      executor: ric-orb/maven_docker
```
Builds java sources using a VM builder
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_build_test:
      context: dev
      cache_key_prefix: "myrepo"
      executor: ric-orb/maven_vm
```
Builds java sources using a custom executor
```yaml
# ...
executors:
  jdk17:
    docker:
      - image: cimg/openjdk:17.0.4
# ...
jobs:
  # ...
  - ric-orb/maven_build_test:
      context: dev
      cache_key_prefix: "myrepo"
      executor: jdk17
```

Builds java sources for a specific app from a monorepo
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_build_test:
      context: dev
      path: "myapp"
      cache_key_prefix: "myrepo"
```

### Maven deploy Java artifact to Artifactory

**Name**: maven_deploy_artifact

**Parameters**:
- **path**: Path of maven module for the app, or "." for single-app-repo. Default: "*.*"
- **cache_key_prefix**: Prefix for the maven artifacts cache-key (used in combination with checksum of *pom_file*). No caching if blank. Default: *blank* 
- **pom_file**: The pom file to be used for the maven build, the checksum used as part of the cache key is calculated from it. Default: "pom.xml"
- **executor**: Executor for the build. Values: *ric-orb/maven_docker*  (default; more lightweight), *ric-orb/maven_vm* (required by builds leveraging testcontainers and therefore depending on docker) or your custom executor

**Examples**

Deploy Java artifact using a docker builder
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_deploy_artifact:
      context: dev
      cache_key_prefix: "myrepo"
      executor: ric-orb/maven_docker
```

Deploy Java artifact using a VM builder
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_deploy_artifact:
      context: dev
      cache_key_prefix: "myrepo"
      executor: ric-orb/maven_vm
```

Deploy Java artifact using a custom executor
```yaml
# ...
executors:
  jdk17:
    docker:
      - image: cimg/openjdk:17.0.4
# ...
jobs:
  # ...
  - ric-orb/maven_deploy_artifact:
      context: dev
      cache_key_prefix: "myrepo"
      executor: jdk17
```

Deploy Java artifact for a specific module from a monorepo
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_deploy_artifact:
      context: dev
      path: "mymodule"
      cache_key_prefix: "myrepo"
```

Deploy Java artifact using a different pom file
```yaml
# ...
jobs:
  # ...
  - ric-orb/maven_deploy_artifact:
      context: dev
      pom_file: "another-pom.xml"
      cache_key_prefix: "myrepo"
```

### Assert that the project version is a SNAPSHOT (for Java applications)

**Name**: maven_assert_snapshot_version

Checks that the Maven project (of the provided pom file) has a SNAPSHOT version, otherwise it fails.
Typically used to force that branch builds of library modules have a -SNAPSHOT version when manually deployed.

**Parameters**:
- **pom_file**: The pom file to use. Default: "pom.xml"

Example:

```yaml
#...
jobs:
  - ric-orb/maven_assert_snapshot_version:
      context: dev
#...
```

### No-Op dummy job

**Name**: no_op

**Parameters**: none

**Examples**

Does nothing. Because sometimes you need a job, but you have nothing to do…
```yaml
# ...
jobs:
  # ...
  - ric-orb/no_op
```

### Build & Quality Gate Job (for Go Applications)

**Name**: go_build_test

**Parameters**:

- **executor**: [circleci executor](https://circleci.com/docs/2.0/configuration-reference/#docker--machine--macos--windows-executor)
- **additional_tests**: is a list of additional steps to run, e.g. run tests on common. The default is: empty list
- **work_dir**: working directory for executing build and test commands

Job runs [`install_build_test` command](../commands/install_build_test.yml), runs additional steps if there are any, and persist resulting `app` file to workspace (to be used by subsequent jobs) 

**Examples**

In this example you configure:
- user defined executor
- custom steps
```yaml
# ...
jobs:
  # ...
- ric-orb/go_build_test:
    executor:
      name: go/default
      tag: '1.17'
    context: dev
    additional_tests:
      - run:
          name: Running tests on common
          command: make test
          working_directory: common
```

This example uses default settings and only the minimum required configuration is added:
```yaml
# ...
jobs:
  # ...
  - ric-orb/quality_gate_job:
      executor:
        name: go/default
        tag: '1.17'
      context: dev
```

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How To Author Commands](https://circleci.com/docs/2.0/reusing-config/#authoring-parameterized-jobs)
 - [Node Orb "test" Job](https://github.com/CircleCI-Public/node-orb/blob/master/src/jobs/test.yml)
