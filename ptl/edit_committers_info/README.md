# Edit your repositories INFO.yaml quickly!

Using that tool it's possible to edit as many INFO.yaml files as you wish. It's not needed to execute the same operations for each of the repository you maintain.

Nowadays only the committer deletion action is available, but addition option should be added soon.

## Requirements

### System requirements

Python 3.10 version is needed to run that tool.

### Virtual environment

It's recommended to create a virtual environment to install all dependencies. Create a virtual env using below command

```
$ python3.10 -m venv .virtualenv
```

Virtual environment will be created under `.virtualenv` directory.
To activate virtual environemnt call

```
$ source .virtualenv/bin/activate
```

### Python requirements

- [click](https://click.palletsprojects.com/en/8.0.x/)
- [GitPython](https://gitpython.readthedocs.io/en/stable/index.html)
- [ruamel.yaml](https://yaml.readthedocs.io/en/latest/)

Install Python requirements calling

```
$ pip install -r requirements.txt
```

## Usage

You need to create a `config` YAML file where you describe what changes you want to perform.
Required YAML config structure:

```
---
repos:  # List of the repositories which are going to be udated.
        # That tool is not smart enough to resolve some conflicts etc.
        # Please be sure that it would be possible to push the change to the gerrit.
        # Remember that commit-msg hook should be executed so add that script into .git/hooks dir
    - path: abs_path_to_the_repo  # Local path to the repository
      branch: master              # Branch which needs to be udated
committers:  # List of the committers which are going to be edited
    - name: Committer Name  # The name of the committer which we would delete or add
      action: Deletion|Addition  # Addition or deletion action
    link: https://link.to.the.tcs.confirmation  # Link to the ONAP TSC action confirmation
commit:  # Configure the commit message
    message:  # List of the commit message lines. That's optional
    - "[INTEGRATION] My awesome first line!"
    - "Even better second one!"
    issue_id: INT-2008  # ONAP's JIRA Issue ID is required in the commit message
```

## Contribute

- Create ONAP Jira ticket
- Edit the code
- Check the linters
  - install tox
    `$ pip install tox`
  - call linters
    `$ tox .`
  - if no errors: push the change
