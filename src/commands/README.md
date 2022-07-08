[Home](../../README.md)

# Commands

Easily add and author [Reusable Commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands) to the `src/commands` directory.

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
...
steps:
  - ric-orb/auth_gke
...
```

### Deploy

**Name**: deploy

This command uses ricardo's tool **isopod** to deploy application to GKE. When `isopod.yml` file is not in project's root
folder,monorepo for example, you can use parameter `config` to point to it or `work_dir` which will execute the isopod in
the `work_dir`. It is depends on **auth_gke** command.

**Parameters**:

- **to** environment to execute deployment. Valid values: *dev* and *prod*. It is passed to isopod. 
  *Default is dev.*
- **config** the isopod configuration file. *Default is isopod.yml*
- **work_dir** working directory for isopod

Example:

```yaml
...
steps:
  - ric-orb/deploy:
      to: prod
      config: foo/isopod.yml
...
```

### Port Forward

**Name:** gke_port_forward

**Parameters**:

- **target** service/pod to which traffic is forwarded
- **port** service/pod port to portforward
- **namespace** k8s namespace where service/pod is located
- **context** k8s context.

It requires app **[dockerize](https://github.com/jwilder/dockerize/).** That means executor should already have this command.

Example:

```yaml
...
steps:
  - ric-orb/gke_port_forward:
      context: some-context
      target: svc/myapp_service
      port: 3333
      namespace: myapp_service
...
```

### Login to Docker Registry

**Name:** login_docker_registry

**Parameters**:

- **url** to the docker registry. Default is empty string so this is not required. Then Docker HUB is target.
- **username** for the docker registry
- **password** for the docker registry

This command executes login from CLI to the target docker registry.

Example:

```yaml
...
steps:
  - ric-orb/login_docker_registry:
      url: http://dhub.com
      username: username
      password: password
```

### Maven Authentication

**Name**: maven_auth

**Parameters**:

- **maven_credentials** environment/context variable which holds base64 encoded content for .m2/settings.xml file. Default is ARTIFACTORY_MAVEN_CREDENTIALS which already defined in our contexts.

Example:

```yaml
steps:
  - ric-orb/maven_auth:
      maven_credentials: MVN_CREDS
```
### Install Build Test

Name: install_build_test

Parameters:

* **work_dir** Not required. Default is `.`(current dir). Sets working directory for install, build, test commands.

This command execute install, build, test make commands. So, to execute it there are two requirements:

* executor have `make` tool installed
* target project have Makefile with goals named: `install`, `build`, `test`

### Quality Gate

**Name**: quality_gate

**Paratemers**:

- **cache_name** Not required. If not specified cache will not be used/created.
- **cache_path** Not required. If not specified cache will not be created.
- **quality_checks** is a list of steps to run. By default they are:

```yaml
quality_checks:
  type: steps
  description: "Steps that will run quality checks"
  default:
    - install_build_test
```

This command executes steps to verify application quality. It uses/creates [CircleCI cache](https://circleci.com/docs/2.0/caching/) if application dependencies are updated.

Example:

```yaml
...
steps:
 - ric-orb/quality_gate:
     quality_checks:
       - ric-orb/maven_auth
       - run: mvn verify
...
```

### Slack Notification For Failure

**Name**: slack_failure

**Parameters**:

- **branches** The list of comma separated branches for which notification should be sent. Default is *master*.
- **webhook** is the slack webhook to channel where notification is sent. Default is stored in context/environment variable SLACK_WEBHOOK(for channel circleci-deployments). Specify only if need to veride.

This command sends notification for branches to the target webhook when job fails. This uses [the slack orb](https://circleci.com/developer/orbs/orb/circleci/slack?version=3.4.2).

Example:

```yaml
...
steps:
  - ric-orb/slack_failure:
      branches: $CIRCLE_BRANCH
      webhook: <slack web hook>
...
```

### Slack Notification For Success

**Name**: slack_success

**Parameters**:

- **branches** The list of comma separated branches for which notification should be sent. Default is *master*.
- **webhook** is the slack webhook to channel where notification is sent. Default is stored in context/environment variable SLACK_WEBHOOK(for channel circleci-deployments). Specify only if need to override.

This command sends notification for branches to the target webhook when job is successful. This uses [the slack orb](https://circleci.com/developer/orbs/orb/circleci/slack?version=3.4.2).

Example:

```yaml
...
steps:
  - ric-orb/slack_success:
      branches: $CIRCLE_BRANCH
      webhook: <slack web hook>
...
```

### Command to save maven artifacts to cache for Java applications
**Name**: java_cache_maven_artifacts

**Parameters**:
- **prefix** Prefix for the cache-key (used in combination with checksum of *pom.xml*)

Example:

Note that you typically want to use a shared prefix for the entire repository in case of monorepo, because otherwise builds of the individual apps will not utilize a shared cache.
```yaml
...
steps:
  - ric-orb/java_cache_maven_artifacts:
      prefix: "myrepo"
...
```

### Command to restore maven artifacts from cache for Java applications
**Name**: java_restore_maven_artifacts

**Parameters**:
- **prefix** Prefix for the cache-key (used in combination with checksum of *pom.xml*); no-op with blank prefix. Default: *blank*

Example:

Note that you typically want to use a shared prefix for the entire repository in case of monorepo, because otherwise builds of the individual apps will not utilize a shared cache.
```yaml
...
steps:
  - ric-orb/java_restore_maven_artifacts:
      prefix: "myrepo"
...
```

### Command to save maven output to workspace for Java applications
**Name**: maven_save_output

**Parameters**:
- **path** Path of maven module for the app, or "." for single-app-repo. Default: "*.*"

Example:

Save maven output directory (target directory containing compiled app) to workspace.
```yaml
...
steps:
  - ric-orb/maven_save_output
```

Save maven output directory to workspace for a specific app from a monorepo.
```yaml
...
steps:
  - ric-orb/maven_save_output:
      path: "myapp"
```

### Command to build and test with maven for Java applications
**Name**: maven_build_test

**Parameters**:
- **path** Path of maven module for the app, or blank for single-app-repo. Default: *blank*

Example:

Build and test java application.
```yaml
...
steps:
  - ric-orb/maven_build_test
```

Build and test java application from a monorepo.
```yaml
...
steps:
  - ric-orb/maven_build_test:
      path: "myapp"
```

### Command to build a docker image with isopod for Java applications
**Name**: java_isopod_build

**Parameters**:
- **path** Path of maven module for the app, or "." for single-app-repo. Default: "*.*"

Example:

Build docker image for java application.
```yaml
...
steps:
  - ric-orb/java_isopod_build
```

Build docker image for java application from a monorepo.
```yaml
...
steps:
  - ric-orb/java_isopod_build:
      path: "myapp"
```

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How to author commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands)
