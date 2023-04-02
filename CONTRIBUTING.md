# Welcome the Siedelwood QSB contributing guide

Thank you for investing your time in contributing to our project!

Read our [Code of Conduct](./CODE_OF_CONDUCT.md) to keep our community approachable and respectable.

In this guide you will get an overview of the contribution workflow from opening an issue, creating a PR, reviewing, and merging the PR.

## New contributor guide

To get an overview of the project, read the [README](README.md). Here are some resources to help you get started with open source contributions:

- [Finding ways to contribute to open source on GitHub](https://docs.github.com/en/get-started/exploring-projects-on-github/finding-ways-to-contribute-to-open-source-on-github)
- [Set up Git](https://docs.github.com/en/get-started/quickstart/set-up-git)
- [Collaborating with pull requests](https://docs.github.com/en/github/collaborating-with-pull-requests)

## Getting started

You can find the qsb and its modules in the folder qsb/lua/modules. The folder qsb/lua/default contains the default scripts to be added to the map. In the folder qsb/exe you will find the tools to build the QSB. For any help or questions you can see us at our [Siedelwood Discord](https://discord.gg/Duhxe7jThs) server.

There are different types of contributions you can do:

- you can review our documentation and wiki to help us avoiding errors.
- you can use the QSB and report us errors you might find in it.
- you can help us with th fixin of known bugs.
- you can write addons to be added to the QSB.

### Issues

#### Create a new issue

If you spot a problem with the documentation, have a crash using the QSB or find any other type of errors, [search if an issue already exists](https://docs.github.com/en/github/searching-for-information-on-github/searching-on-github/searching-issues-and-pull-requests#search-by-the-title-body-or-comments). If a related issue doesn't exist, you can open a new issue using a relevant [issue form](https://github.com/Siedelwood/Revision/issues/new/choose). Bare in mind that we also collect Problems in the QSB in our [Siedelwood Discord](https://discord.gg/Duhxe7jThs) server.

#### Solve an issue

Scan through our [existing issues](https://github.com/Siedelwood/Revision/issues) to find one that interests you. As a general rule, we don’t assign issues to anyone. If you find an issue to work on, you are welcome to open a PR with a fix.

### Make Changes

#### Make changes in the UI

Click **Make a contribution** at the bottom of any readme or wiki page to make small changes such as a typo, sentence fix, or a broken link. This takes you to the `.md` file where you can make your changes and [create a pull request](#pull-request) for a review. Keep in mind that the wiki sites for the QSB documentation itself are generated automatically and therefor your changes will be overwritten at some point. Those changes need to be done in the lua files.

#### Make changes locally

1. Fork the repository.
- Using GitHub Desktop:
  - [Getting started with GitHub Desktop](https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/getting-started-with-github-desktop) will guide you through setting up Desktop.
  - Once Desktop is set up, you can use it to [fork the repo](https://docs.github.com/en/desktop/contributing-and-collaborating-using-github-desktop/cloning-and-forking-repositories-from-github-desktop)!

- Using the command line:
  - [Fork the repo](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo#fork-an-example-repository) so that you can make your changes without affecting the original project until you're ready to merge them.

2. Install an editor that allows you to work with lua in a way you are confortable with.

3. If you intend to build the QSB you created or worked on you might need some additional tools like a working lua installation or the github bash on windows.

4. Create a working branch and start with your changes!

### Commit your update

Commit the changes once you are happy with them. Don't forget to self-review to speed up the review process.

### Pull Request

When you're finished with the changes, create a pull request, also known as a PR.
- Fill the "Ready for review" template so that we can review your PR. This template helps reviewers understand your changes as well as the purpose of your pull request.
- Don't forget to [link PR to issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue) if you are solving one.
- Enable the checkbox to [allow maintainer edits](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/allowing-changes-to-a-pull-request-branch-created-from-a-fork) so the branch can be updated for a merge.
Once you submit your PR, a Docs team member will review your proposal. We may ask questions or request additional information.
- We may ask for changes to be made before a PR can be merged, either using [suggested changes](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/incorporating-feedback-in-your-pull-request) or pull request comments. You can apply suggested changes directly through the UI. You can make any other changes in your fork, then commit them to your branch.
- As you update your PR and apply changes, mark each conversation as [resolved](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/commenting-on-a-pull-request#resolving-conversations).
- If you run into any merge issues, checkout this [git tutorial](https://github.com/skills/resolve-merge-conflicts) to help you resolve merge conflicts and other issues.

### Your PR is merged!

Once your PR is merged, your contributions will be publicly visible on the [Siedelwood Repository](https://github.com/Siedelwood/Revision).

## Our Workflow

The QSB has to active versions. There is the release version that is stable and meant to be used by the mappers of the Settlers-RoaE. The development version contains current development features, that might still contain some bugs or an API that might still change. If you are using the release version you can be sure, that the API we provide will be stable over time and releases. Both these versions will be represented by a branch. One other important branch is the release-hotfix branch that is only meant to fix errors in the release version. If you want to contribute to our Project, make sure to always branch the release-hotfix or the development branches. We will not consider any PRs coming from other branches.

## Windows

The QSB can be developed on any system, though the Game using it, The Settlers RoaE, will only run on Windows.
