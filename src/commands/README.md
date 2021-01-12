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

This command uses ricardo's tool **isopod** to deploy application to GKE. It is dependant on **auth_gke** command.

**Parameters**:

- **to :** environment to execute deployment. Valid values: *dev* and *prod*. It is passed to isopod. 
  *Default is dev.*

Example:

```yaml
...
steps:
  - ric-orb/deploy:
      to: prod
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

### Quality Gate

**Name**: quality_gate

**Paratemers**:

- **cache_name** Not required. If not specified cache will not be used/created.
- **cache_path** Not required. If not specified cache will not be created.
- **quality_checks** is a list of steps to run. By default they are:

```
make install
make build
make test
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

- **branches** The list of comma separated branches for which notification should be sent. Default is *master.*
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

- **branches** The list of comma separated branches for which notification should be sent. Default is *master.*
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

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How to author commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands)
