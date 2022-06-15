# Ricardo Orb

[![CircleCI Build Status](https://circleci.com/gh/ricardo-ch/ricardo-orbs.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/ricardo-ch/ricardo-orbs) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ricardo/ric-orb)](https://circleci.com/orbs/registry/orb/ricardo/ric-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/ricardo-ch/ricardo-orbs/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)



A starter template for orb projects. Build, test, and publish orbs automatically on CircleCI with [Orb-Tools](https://circleci.com/orbs/registry/orb/circleci/orb-tools).

Additional READMEs are available in each directory.


## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/ricardo/ricardo-orbs) - The official registry page of this orb for all versions, executors, commands, and jobs described.
[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using and creating CircleCI Orbs.

### How to Contribute

We welcome [issues](https://github.com/ricardo-ch/ricardo-orbs/issues) to and [pull requests](https://github.com/ricardo-ch/ricardo-orbs/pulls) against this repository!

### How to Publish
* Create and push a branch with your new features.
* When ready to publish a new production version, squash and merge the changes into the main branch with a commit title including a special semver tag: `[semver:<segement>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* On CircleCi, ensure to manually approve the workflow. After approval, the orb will automatically be published to the Orb Registry.

For further questions/comments about this or other orbs, visit the Orb Category of [CircleCI Discuss](https://discuss.circleci.com/c/orbs).

## Status

This orb is not listed. To list it again use `circleci orb unlist <namespace>/<orb> <true|false> [flags]` or [see docs](https://circleci-public.github.io/circleci-cli/circleci_orb_unlist.html).

The currently released version is 1.6.0.

## Known Issue

You may get this error when pushing a new PR,

```bash
The dev version of ricardo/ric-orb@dev:alpha has expired. Dev versions of orbs are only valid for 90 days after publishing.
```

If you see this error, you need to publish a dev:alpha version manually. The fix is to run this:

```bash
circleci orb pack ./src | circleci orb validate -
circleci orb pack ./src | circleci orb publish -  ricardo/ric-orb@dev:alpha
```

## Usage

To use the orb add this:
```yaml
orbs:
    ric-orb: ricardo/ric-orb@1.6.0
```

to your `.circleci/config.yml` file.

Usage, examples and docs:

* [Commands](src/commands/README.md)
* [Executors](src/executors/README.md)
* [Jobs](src/jobs/README.md)
* [Scripts](src/scripts/README.md)
* [Orb](src/README.md)
* [Examples](src/examples/README.md)