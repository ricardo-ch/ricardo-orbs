[Home](../../README.md)

# Commands

Easily add and author [Reusable Commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands) to the [src/commands directory](.).

Each _YAML_ file within this directory will be treated as an orb command, with a name which matches its filename.

### Authenticate To GKE

**Name**: auth_gke

This command authenticate to GKE so operations with GKE are possible. Requires context/environment variables to be defined:

- GCLOUD_SERVICE_KEY
- GOOGLE_PROJECT_ID
- GKE_COMPUTE_ZONE
- GKE_CLUSTER_NAME

Example:

```yaml
#...
steps:
  - ric-orb/auth_gke
#...
```

### Setup Remote Docker

**Name**: remote_docker

This command wraps the built-in setup_remote_docker to make it work with optional version parameter.

**Parameters**:
- **docker_version**: [see docs](https://circleci.com/docs/2.0/building-docker-images/#docker-version). Default is *''* (which defaults to CircleCI's default)
- **docker_layer_caching**: for enabling [docker layer caching](https://circleci.com/docs/2.0/docker-layer-caching/). Default is *true*

Example:
```yaml
#...
steps:
  - ric-orb/remote_docker:
      docker_version: '20.10.17'
      docker_layer_caching: true
#...
```

### Docker build & push

**Name**: docker_build_push

Build and push the docker image with docker.

**Parameters**:
- **image_name**: The Docker image name (without the path, e.g. search-solr)
- **work_dir**: Working directory for the command. Deafult is *"."*

Example:

```yaml
#...
steps:
  - ric-orb/docker_build_push:
      image_name: my_image
      work_dir: my_maven_module
#...
```

### Isopod build & push

**Name**: build_push
(TODO: should be called isopod_build_push, but that would be a breaking change)

This command uses ricardo's tool **isopod** to build and push a docker image. When `isopod.yml` file is not in project's root
folder (e.g. monorepo), you can use the parameter `config` to point to it or `work_dir` which will execute the isopod in
the `work_dir`.

**Parameters**:
- **config**: the isopod configuration file. Default is *isopod.yml*
- **work_dir**: working directory for isopod. Default is *"."*

Example:

```yaml
#...
steps:
  - ric-orb/build_push:
      config: myapp/isopod.yml
#...
```

### Isopod deploy

**Name**: deploy
(TODO: should be called isopod_build_push, but that would be a breaking change)

This command uses ricardo's tool **isopod** to deploy application to GKE. When `isopod.yml` file is not in project's root
folder,monorepo for example, you can use parameter `config` to point to it or `work_dir` which will execute the isopod in
the `work_dir`. It is depends on **auth_gke** command.

**Parameters**:
- **to**: environment to execute deployment. Valid values: *dev* and *prod*. It is passed to isopod.
  *Default is dev.*
- **config**: the isopod configuration file. Default is *isopod.yml*
- **work_dir**: working directory for isopod. Default is *"."*

Example:

```yaml
#...
steps:
  - ric-orb/deploy:
      to: prod
      config: foo/isopod.yml
#...
```

### GKE Port Forward

**Name:** gke_port_forward

**Parameters**:
- **target**: service/pod to which traffic is forwarded
- **port**: service/pod port to portforward
- **local_port**: (optional) service/pod port to portforward on the LOCAL (CircleCI) side. If missing or 0, it is the same as port
- **namespace**: k8s namespace where service/pod is located
- **context**: k8s context.

**Dependencies:**

Requires **[dockerize](https://github.com/jwilder/dockerize/)** installed on your executor.

Example:

```yaml
#...
steps:
  - ric-orb/gke_port_forward:
      context: some-context
      target: svc/myapp_service
      port: 3333
      namespace: myapp_service
#...
```

### Login to Docker Registry

**Name:** login_docker_registry

**Parameters**:
- **url**: to the docker registry. Default is empty string so this is not required. Then Docker HUB is target.
- **username**: for the docker registry
- **password**: for the docker registry

This command executes login from CLI to the target docker registry.

Example:

```yaml
#...
steps:
  - ric-orb/login_docker_registry:
      url: http://dhub.com
      username: username
      password: password
#...
```

### Maven setup ("authentication")

**Name**: maven_auth
(TODO: should be called maven_setup, but that would be a breaking change)

**Parameters**:
- **maven_credentials**: environment/context variable which holds base64 encoded content for .m2/settings.xml file. Default is ARTIFACTORY_MAVEN_CREDENTIALS
  which already defined in our contexts.

Example:

```yaml
#...
steps:
  - ric-orb/maven_auth:
      maven_credentials: MVN_CREDS
#...
```

### Make install & build & test

Name: install_build_test
(TODO: should be called make_install_build_test, but that would be a breaking change)

**Parameters**:
- **work_dir**: Not required. Default is `.`(current dir). Sets working directory for install, build, test commands.

This command executes make goals install, build, and test. Therefore, execution has requirements:

**Dependencies**:

- `make` must be installed on executor
- target project must have a Makefile with goals `install`, `build`, and `test`

### Quality Gate

**Name**: quality_gate

Generic quality gate command

**Parameters**:
- **cache_name**: Not required. If not specified cache will not be used/created.
- **cache_path**: Not required. If not specified cache will not be created.
- **quality_checks**: is a list of steps to run. By default, this is:

```yaml
#...
quality_checks:
  type: steps
  description: "Steps that will run quality checks"
  default:
    - install_build_test
#...
```

This command executes steps to verify application quality. It uses/creates [CircleCI cache](https://circleci.com/docs/2.0/caching/) if application dependencies
are updated.

Example:

```yaml
#...
steps:
  - ric-orb/quality_gate:
      quality_checks:
        - ric-orb/maven_auth
        - run: mvn verify
#...
```

### Slack Notification for Failure

**Name**: slack_failure

**Parameters**:
- **branches**: The list of comma separated branches for which notification should be sent. Default is *master*.
- **webhook**: is the slack webhook to channel where notification is sent. Default is stored in context/environment variable SLACK_WEBHOOK (for channel
  circleci-deployments). Specify only if you need to override.

This command sends a notification to target webhook if respective job failed. This uses the
circleCI [slack orb](https://circleci.com/developer/orbs/orb/circleci/slack?version=3.4.2).

Example:

```yaml
#...
steps:
  - ric-orb/slack_failure:
      branches: $CIRCLE_BRANCH
      webhook: <slack web hook>
#...
```

### Slack Notification for Success

**Name**: slack_success

**Parameters**:
- **branches**: The list of comma separated branches for which notification should be sent. Default is *master*.
- **webhook**: is the slack webhook to channel where notification is sent. Default is stored in context/environment variable SLACK_WEBHOOK(for channel
  circleci-deployments). Specify only if you need to overwrite.

This command sends a notification to target webhook if respective job succeeded. This uses the
circleCI [slack orb](https://circleci.com/developer/orbs/orb/circleci/slack?version=3.4.2).

Example:

```yaml
#...
steps:
  - ric-orb/slack_success:
      branches: $CIRCLE_BRANCH
      webhook: <slack web hook>
#...
```

### Command to save maven artifacts to cache (for Java applications)

**Name**: maven_cache_artifacts

**Parameters**:
- **prefix**: Prefix for the cache-key (used in combination with and checksum of *pom_file* as well as *path*)
- **path**: Path of maven module (or "." for single-app-repo') for the cache-key (used in combination with *prefix* and checksum of *pom_file*). Default: "*.*"
- **pom_file**: The pom file to be used for the maven build, the checksum used as part of the cache key is calculated from it. Default: "pom.xml"

Example:

```yaml
#...
steps:
  - ric-orb/maven_cache_artifacts:
      prefix: "myrepo"
#...
```

Note that you typically want to use a shared prefix for the entire repository in case of monorepo, because this way the individual apps can fall back to each
other's cache.

```yaml
#...
steps:
  - ric-orb/maven_cache_artifacts:
      prefix: "my-monorepo"
      path: "app1"
#...
```

### Command to restore maven artifacts from cache (for Java applications)

**Name**: maven_restore_artifacts

**Parameters**:
- **prefix**: Prefix for the cache-key (used in combination with checksum of *pom_file* as well as *path*); no-op with blank prefix. Default: *blank*
- **path**: Path of maven module (or "." for single-app-repo') for the cache-key (used in combination with *prefix* and checksum of *pom_file*). Default: "*.*"
- **pom_file**: The pom file to be used for the maven build, the checksum used as part of the cache key is calculated from it. Default: "pom.xml"

Example:

```yaml
#...
steps:
  - ric-orb/maven_restore_artifacts:
      prefix: "myrepo"
#...
```

Note that you typically want to use a shared prefix for the entire repository in case of monorepo, because this way the individual apps can fall back to each
other's cache.

```yaml
#...
steps:
  - ric-orb/maven_cache_artifacts:
      prefix: "my-monorepo"
      path: "app1"
#...
```

### Command to save maven output to workspace (for Java applications)

**Name**: maven_save_output

**Parameters**:
- **path**: Path of maven module for the app, or "." for single-app-repo. Default: "*.*"

Example:

Save maven output directory (target directory containing compiled app) to workspace.

```yaml
#...
steps:
  - ric-orb/maven_save_output
#...
```

Save maven output directory to workspace for a specific app from a monorepo.

```yaml
#...
steps:
  - ric-orb/maven_save_output:
      path: "myapp"
#...
```

### Command to assert that a Maven expression matches a pattern (for Java applications)

**Name**: maven_assert_expression

**Parameters**:
- **expression**: An expression to evaluate, following the Maven expression syntax but without any surrounding ${...}.
- **pattern**: The regex pattern to match against the expression.
- **pom_file**: The pom file to use. Default: "pom.xml"

Example:

Assert that the project version finishes with '-SNAPSHOT'

```yaml
#...
steps:
  - ric-orb/maven_assert_expression:
      expression: 'project.version'
      pattern: '^.*-SNAPSHOT$'
#...
```

## See:

- [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
- [How to author commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands)
