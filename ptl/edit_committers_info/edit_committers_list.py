"""Automate the INFO.yaml update."""
"""
   Copyright 2021 Deutsche Telekom AG

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
"""

from enum import Enum
from itertools import chain, zip_longest
from pathlib import Path
from typing import Dict, Iterator, List, Optional, Tuple

import click
import git
from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import SingleQuotedScalarString


class CommitterActions(Enum):
    """Committer Actions enum.

    Available actions:
     * Addition - will add the commiter with their info into
        the committers list and the tsc information would be added
     * Deletion - commiter will be deleted from the committers list
        and the tsc information would be added

    """

    ADDITION = "Addition"
    DELETION = "Deletion"


class CommitterChange:
    """Class representing the change on the committers list which needs to be done."""

    def __init__(
        self,
        name: str,
        action: CommitterActions,
        link: str,
        email: str = None,
        company: str = None,
        committer_id: str = None,
        timezone: str = None,
    ) -> None:
        """Initialize the change object.

        Args:
            name (str): Committer name
            action (CommitterActions): Action to be done
            link (str): Link to the TSC confirmation
            email (str, optional): Committer's e-mail. Needed only for addition.
                Defaults to None.
            company (str, optional): Committer's company name. Needed only for addition.
                Defaults to None.
            committer_id (str, optional): Committer's LF ID. Needed only for addition.
                Defaults to None.
            timezone (str, optional): Committer's timezone. Needed only for addition.
                Defaults to None.
        """
        self._committer_name: str = name
        self._action: CommitterActions = action
        self._link: str = link

    @property
    def action(self) -> CommitterActions:
        """Enum representing an action which is going to be done by the change.

        Returns:
            CommitterActions: One of the CommittersActions enum value.

        """
        return self._action

    @property
    def committer_name(self) -> str:
        """Committer name property.

        Returns:
            str: Name provided during the initialization.

        """
        return self._committer_name

    @property
    def tsc_change(self) -> Dict[str, str]:
        """TSC change.

        Dictionary which is going to be added into
            INFO.yaml file 'tsc' section.
        Values are different for Addition and Deletion
            actions.

        Returns:
            Dict[str, str]: TSC section entry

        """
        # Start ignoring PyLintBear
        match self.action:
            case CommitterActions.ADDITION:
                return self.tsc_change_addition
            case CommitterActions.DELETION:
                return self.tsc_change_deletion
        # Stop ignoring

    @property
    def tsc_change_addition(self) -> Dict[str, str]:
        """Addition tsc section entry value.

        Value which is going to be added into 'tsc' section

        Raises:
            NotImplementedError: That method is not implemented yet

        Returns:
            Dict[str, str]: TSC section value
        """
        raise NotImplementedError

    @property
    def tsc_change_deletion(self) -> Dict[str, str]:
        """Addition tsc section entry value.

        Value which is going to be added into 'tsc' section

        Returns:
            Dict[str, str]: TSC section value
        """
        return {
            "type": self.action.value,
            "name": self.committer_name,
            "link": self._link,
        }


class YamlConfig:
    """YAML config class which corresponds the configuration YAML file needed to be provided by the user.

    Required YAML config structure:

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
    """

    def __init__(self, yaml_file_path: Path) -> None:
        """Initialize yaml config object.

        Args:
            yaml_file_path (Path): Path to the config file provided by the user

        """
        with yaml_file_path.open("r") as yaml_file:
            self._yaml = YAML().load(yaml_file.read())

    @property
    def repos_data(self) -> Iterator[Tuple[Path, str]]:
        """Repositories information iterator.

        Returns the generator with the tuples on which:
            * first element is a path to the repo
            * second element is a branch name which
                is going to be used to prepare a change
                and later push into

        Yields:
            Iterator[Tuple[Path, str]]: Tuples of repository data: repo local abs path and branch name

        """
        for repo_info in self._yaml["repos"]:
            yield (Path(repo_info["path"]), repo_info["branch"])

    @property
    def committers_changes(self) -> Iterator[CommitterChange]:
        """Committer changes iterator.

        Returns the generator with `CommitterChange` class instances

        Yields:
            Iterator[CommitterChange]: Committer changes generator

        """
        for committer_change in self._yaml["committers"]:
            # Start ignoring PyLintBear
            match action := CommitterActions(committer_change["action"]):
                case CommitterActions.ADDITION:
                    continue  # TODO: Add addition support
                case CommitterActions.DELETION:
                    yield CommitterChange(
                        name=committer_change["name"],
                        action=action,
                        link=committer_change["link"],
                    )
            # Stop ignoring

    @property
    def issue_id(self) -> str:
        """Onap's Jira issue id.

        That issue id would be used in the commit message.

        Returns:
            str: ONAP's Jira issue ID

        """
        return self._yaml["commit"]["issue_id"]

    @property
    def commit_msg(self) -> Optional[List[str]]:
        """Commit message lines list.

        Optional, if user didn't provide it in the config file
            it will returns None

        Returns:
            Optional[List[str]]: List of the commit message lines or None

        """
        return self._yaml["commit"].get("message")


class OnapRepo:
    """ONAP repo class."""

    def __init__(self, git_repo_path: Path, git_repo_branch: str) -> None:
        """Initialize the Onap repo class object.

        During that method an attempt will be made to change the branch to the one specified by the user.

        Args:
            git_repo_path (Path): Repository local abstract path
            git_repo_branch (str): Branch name

        Raises:
            ValueError: Branch provided by the user doesn't exist

        """
        self._repo: git.Repo = git.Repo(git_repo_path)
        self._branch: str = git_repo_branch
        if self._repo.head.ref.name != self._branch:
            for branch in self._repo.branches:
                if branch.name == self._branch:
                    branch.checkout()
                    break
            else:
                raise ValueError(
                    f"Branch {self._branch} doesn't exist in {self._repo.working_dir} repo"
                )

    @property
    def git(self) -> git.Repo:
        """Git repository object.

        Returns:
            git.Repo: Repository object.

        """
        return self._repo

    @property
    def info_file_path_abs(self) -> Path:
        """Absolute path to the repositories INFO.yaml file.

        Concanenated repository working tree directory and INFO.yaml

        Returns:
            Path: Repositories INFO.yaml file abs path

        """
        return Path(self._repo.working_tree_dir, "INFO.yaml")

    def push_the_change(self, issue_id: str, commit_msg: List[str] = None) -> None:
        """Push the change to the repository.

        INFO.yaml file will be added to index and then the commit message has to be created.
        If used doesn't provide commit message in the config file the default one will be used.
        Commit command will look:
        `git commit -m <First line> -m <Second line> ... -m <Last line> -m Issue-ID: <issue ID> -s`
        And push command:
        `git push origin HEAD:refs/for/<branch defined by user>`

        Args:
            issue_id (str): ONAP's Jira issue ID
            commit_msg (List[str], optional): Commit message lines. Defaults to None.

        """
        index = self.git.index
        index.add(["INFO.yaml"])
        if not commit_msg:
            commit_msg = ["Edit INFO.yaml file."]
        commit_msg_with_m = list(
            chain.from_iterable(zip_longest([], commit_msg, fillvalue="-m"))
        )
        self.git.git.execute(
            [
                "git",
                "commit",
                *commit_msg_with_m,
                "-m",
                "That change was done by automated integration tool to maintain commiters list in INFO.yaml",
                "-m",
                f"Issue-ID: {issue_id}",
                "-s",
            ]
        )
        self.git.git.execute(["git", "push", "origin", f"HEAD:refs/for/{self._branch}"])
        print(f"Pushed successfully to {self._repo} respository")


class InfoYamlLoader(YAML):
    """Yaml loader class.

    Contains the options which are same as used in the INFO.yaml file.
    After making changes and save INFO.yaml file would have same format as before.
    Several options are set:
        * indent - 4
        * sequence dash indent - 4
        * sequence item indent - 6
        * explicit start (triple dashes at the file beginning '---')
        * preserve quotes - keep the quotes for all strings loaded from the file.
            It doesn't mean that all new strings would also have quotas.
            To make new strings be stored with quotas ruamel.yaml.scalarstring.SingleQuotedScalarString
            class needs to be used.
    """

    def __init__(self, *args, **kwargs) -> None:
        """Initialize loader object."""
        super().__init__(*args, **kwargs)
        self.preserve_quotes = True
        self.indent = 4
        self.sequence_dash_offset = 4
        self.sequence_indent = 6
        self.explicit_start = True


class InfoYamlFile:
    """Class to store information about INFO.yaml file.

    It's context manager class, so it's possible to use it by
    ```
    with InfoTamlFile(Path(...)) as info_file:
        ...
    ```
    It's recommended because at the end all changes are going to be
        saved on the same path as provided by the user (INFO.yaml will
        be overrited)

    """

    def __init__(self, info_yaml_file_path: Path) -> None:
        """Initialize the object.

        Args:
            info_yaml_file_path (Path): Path to the INFO.yaml file

        """
        self._info_yaml_file_path: Path = info_yaml_file_path
        self._yml = InfoYamlLoader()
        with info_yaml_file_path.open("r") as info:
            self._info = self._yml.load(info.read())

    def __enter__(self):
        """Enter context manager."""
        return self

    def __exit__(self, *_):
        """Exit context manager.

        File is going to be saved now.

        """
        with self._info_yaml_file_path.open("w") as info:
            self._yml.dump(self._info, info)

    def perform_committer_change(self, committer_change: CommitterChange) -> None:
        """Perform the committer change action.

        Depends on the action change the right method is going to be executed:
         * delete_committer for Deletion.
        For the addition action ValueError exception is going to be raised as
            it's not supported yet

        Args:
            committer_change (CommitterChange): Committer change object

        Raises:
            ValueError: Addition action called - not supported yet

        """
        match committer_change.action:
            case CommitterActions.ADDITION:
                raise ValueError("Addition action not supported")
            case CommitterActions.DELETION:
                self.delete_committer(committer_change.committer_name)
        self.add_tsc_change(committer_change)

    def delete_committer(self, name: str) -> None:
        """Delete commiter action execution.

        Based on the name commiter is going to be removed from the INFO.yaml 'committers' section.

        Args:
            name (str): Committer name to delete.

        Raises:
            ValueError: Committer not found on the list

        """
        for index, committer in enumerate(self._info["committers"]):
            if committer["name"] == name:
                del self._info["committers"][index]
                return
        raise ValueError(f"Committer {name} is not on the committer list")

    def add_tsc_change(self, committer_change: CommitterChange) -> None:
        """Add Technical Steering Committee entry.

        All actions need to be confirmed by the TSC. That entry proves that
            TSC was informed and approved the change.

        Args:
            committer_change (CommitterChange): Committer change object.

        """
        self._info["tsc"]["changes"].append(
            {
                key: SingleQuotedScalarString(value)
                for key, value in committer_change.tsc_change.items()
            }
        )


@click.command()
@click.option(
    "--changes_yaml_file_path",
    "changes_yaml_file_path",
    required=True,
    type=click.Path(exists=True),
    help="Path to the file where chages are described",
)
def update_infos(changes_yaml_file_path):
    """Run the tool."""
    yaml_config = YamlConfig(Path(changes_yaml_file_path))
    for repo, branch in yaml_config.repos_data:
        onap_repo = OnapRepo(repo, branch)
        with InfoYamlFile(onap_repo.info_file_path_abs) as info:
            for committer_change in yaml_config.committers_changes:
                info.perform_committer_change(committer_change)
        onap_repo.push_the_change(yaml_config.issue_id, yaml_config.commit_msg)


if __name__ == "__main__":
    update_infos()
