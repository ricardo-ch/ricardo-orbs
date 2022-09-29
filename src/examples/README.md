[Home](../../README.md)

# Usage Examples

Easily author and add [Usage Examples](https://circleci.com/docs/2.0/orb-author/#providing-usage-examples-of-orbs) to the [src/examples directory](.).

Each _YAML_ file within this directory will be treated as an orb usage example, with a name which matches its filename.

Usage examples should contain clear use-case based example configurations for using the orb.

### Example One

File: [service_one.yml](service_one.yml)

Here many of defaults are omitted. Values are stored in different context/environment variables.
Plus some yaml magic.

This example shows:
- Specific version of the isopod.
- specify username/password for docker hub (public) when not usig default
- specify username/password for private docker hub when not usig default
- this is for go application
- custom quality checks

### Example Two

File: [service_two](service_two.yml)

Used defaults.

In this example shows:
- this is for go application
- slack default config
- slack custom config

### Example Tree

File: [service_tree](service_tree.yml)

In this example shows:
- no slack
- java app

### Example Four

File: [service_four](service_four.yml)

In this example shows:
- no slack
- node app
- custom deployment (all steps)

### Example Java Monorepo
Files:
- [java_monorepo_setup.yml](java_monorepo_setup.yml)
- [java_monorepo_workflows.yml](java_monorepo_workflows.yml)

Example configuration for a java monorepo shows how to:
- use path-filtering to trigger workflow for specific maven module
- configure the build/deployment workflow with minimal custom configuration 


### Example Java Single-App Repo
Files:
- [java_singleapprepo.yml](java_singleapprepo.yml)

Example configuration for a repo containing a single java app
- configure the build/deployment workflow with minimal custom configuration

### Example Go Monorepo
Files:
- [go_monorepo_setup.yml](go_monorepo_setup.yml)
- [go_monorepo_workflows.yml](go_monorepo_workflows.yml)

Example configuration for a go monorepo shows how to:
- use path-filtering to trigger workflow for specific go module
- configure the build/deployment workflow with minimal custom configuration

### Example Go Single-App Repo
Files:
- [go_singleapprepo.yml](go_singlerepo.yml)

Example configuration for a repo containing a single go app
- configure the build/deployment workflow with minimal custom configuration

## See:
- [Providing Usage examples](https://circleci.com/docs/2.0/orb-author/#providing-usage-examples-of-orbs)
