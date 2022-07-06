[Home](../../README.md)

# Executors

Easily author and add [Parameterized Executors](https://circleci.com/docs/2.0/reusing-config/#executors) to the `src/executors` directory.

Each _YAML_ file within this directory will be treated as an orb executor, with a name which matches its filename.

Executors can be used to parameterize the same environment across many jobs. Orbs nor jobs _require_ executors, but may be helpful in some cases, such as: [parameterizing the Node version for a testing job so that matrix testing may be used](https://circleci.com/orbs/registry/orb/circleci/node#usage-run_matrix_testing).

View the included _[hello.yml](./hello.yml)_ example.

### Isopod

**Name**: isopod

**Parameters**:

- **tag** isopod version, default *master*
- **username** username for docker registry
- **password** password for docker registry

**Isopod** executor is parametrised executor with [isopod](https://github.com/ricardo-ch/isopod) installed. It is used for running jobs in this orb.

### Docker based Java Builder

**Name**: java_builder_docker

**Parameters**: note that all java_builder_* have a shared set of parameters (signature) which allows mimicking polymorph behaviour

- **image** Docker image to use for the executor. Default *cimg/openjdk:11.0*
- **docker_hub_username** Docker hub credentials to download the executor image
- **docker_hub_password** Docker hub credentials to download the executor image

A parametrised docker executor with java installed (see also [Convenience Images: cimg/openjdk:\<tag>](https://circleci.com/developer/images/image/cimg/openjdk)). It is used for running java jobs in this orb.

### VM based Java Builder

**Name**: java_builder_vm

**Parameters**: note that all java_builder_* have a shared set of parameters (signature) which allows mimicking polymorph behaviour

- **image** VM image to use for the executor. Default *ubuntu-2004:202010-01*
- **docker_hub_username** (Unused, but required to match java_builder_* signature which allows mimicking polymorph behaviour)
- **docker_hub_password** (Unused, but required to match java_builder_* signature which allows mimicking polymorph behaviour)

A parametrised vm executor with java installed. It is used for running java jobs in this orb.

This executor is required in case a build depends on a running docker instance to execute testcontainers.

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How To Author Executors](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-executors)
 - [Node Orb Executor](https://github.com/CircleCI-Public/node-orb/blob/master/src/executors/default.yml)
