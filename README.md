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

### How to set up publishing in CircleCI

Read [official docs](https://support.circleci.com/hc/en-us/articles/4414672675099-How-to-enable-users-who-are-not-an-organization-owner-to-publish-an-Orb).

Required:
* Access to github account that is org owner (see 1Password)
* Install CircleCi CLI tool [from here](https://circleci.com/docs/local-cli/)

##### Use org owner account

If by any chance you are logged in GitHub logout and login back as org owner. Then login to CircleCI with 
GitHub account.

##### Update ssh key

In CircleCI go to the project settings for this orb. On left side choose **SSH Keys**.
If there is user key set, remove it and new one. You do not need to execute any command. Just clicking on **X** will remove
key and **Add Deploy Key** in *User Key*. 

##### Update CircleCI API Key

1. Go to [user settings](https://app.circleci.com/settings/user). 
2. Click [Personal API Tokens](https://app.circleci.com/settings/user/tokens) on the left.
3. Click the Create New Token button.
4. In the Token name field, type a memorable name for the token. 
5. Click the Add API Token button.
6. After the token appears, copy and paste it to another location(1Password). You will not be able to view the token again.

##### Update CIRCLE_TOKEN variable

1. Go to the project settings.
2. Select on the left **Environment Variables**.
3. If there is variable named **CIRCLE_TOKEN** remove it, by clicking on **X** next to it.
4. Click on button **Add Environment Variable** and for name enter **CIRCLE_TOKEN** and for value API token value you just created.

##### Setup API Token in CircleCI CLI

In CLI run `circleci setup`, follow the steps. When asked do you want to change API token choose **Yes**.
For token value set one you generated.

## Status

This orb is not listed. To list it again use `circleci orb unlist <namespace>/<orb> <true|false> [flags]` or [see docs](https://circleci-public.github.io/circleci-cli/circleci_orb_unlist.html).

The currently released version is 5.6.0.

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
    ric-orb: ricardo/ric-orb@5
```

to your `.circleci/config.yml` file.

Usage, examples and docs:

* [Commands](src/commands/README.md)
* [Executors](src/executors/README.md)
* [Jobs](src/jobs/README.md)
* [Scripts](src/scripts/README.md)
* [Orb](src/README.md)
* [Examples](src/examples/README.md)
