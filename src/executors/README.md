[Home](../../README.md)

# Executors

Easily author and add [Parameterized Executors](https://circleci.com/docs/2.0/reusing-config/#executors) to the [src/executors directory](.).

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

**Name**: maven_docker

**Parameters**:

- **tag** cimg/openjdk image version, default *11.0*


A docker executor with java 11 installed (see also [Convenience Images: cimg/openjdk:11.0](https://circleci.com/developer/images/image/cimg/openjdk)). It is used for running java jobs in this orb.

### VM based Java Builder

**Name**: maven_vm

**Parameters**: none

A vm executor (ubuntu-2022:current) with java 11 installed. It is used for running java jobs in this orb.

This executor is required in case a build depends on a running docker instance to execute testcontainers.


## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How To Author Executors](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-executors)
 - [Node Orb Executor](https://github.com/CircleCI-Public/node-orb/blob/master/src/executors/default.yml)
