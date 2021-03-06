#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Create configuration for code search."""

import argparse
import json
import urllib.request
import sys

DEFAULT_GERRIT = "gerrit.onap.org"
API_PREFIX = "/r"
API_PROJECTS = "/projects/"

MAGIC_PREFIX = ")]}'"

CODE_LOCATION = "{path}{anchor}"
GITWEB_ANCHOR = "#l{line}"
GIT_ANCHOR = "#n{line}"

DEFAULT_POLL = 3600

def get_projects_list(gerrit):
    """Request list of all available projects from ONAP Gerrit."""
    resp = urllib.request.urlopen("https://{}{}{}".format(gerrit, API_PREFIX, API_PROJECTS))
    resp_body = resp.read()

    no_magic = resp_body[len(MAGIC_PREFIX):]
    decoded = no_magic.decode("utf-8")
    projects = json.loads(decoded)

    return projects.keys()


def create_repos_list(projects, gerrit, ssh, git, poll):
    """Create a map of all projects to their repositories' URLs."""
    gerrit_url = "https://{}{}".format(gerrit, API_PREFIX)
    git_url = "git://{}".format(git)
    gerrit_project_url_base = "{}/{{}}.git".format(gerrit_url)
    gitweb_code_url_base = "{}/gitweb?p={{}}.git;hb=HEAD;a=blob;f=".format(gerrit_url)
    git_project_url_base = "{}/{{}}.git".format(git_url)

    repos_list = {}
    for project in projects:
        project_url = gerrit_project_url_base.format(project)
        code_url = gitweb_code_url_base.format(project) + CODE_LOCATION
        anchor = GITWEB_ANCHOR

        if ssh and len(ssh) == 2:
            user, port = ssh[0], ssh[1]
            project_url = "ssh://{}@{}:{}/{}.git".format(user, gerrit, port, project)
        if git:
            code_url = "https://{}/{}/tree/".format(git, project) + CODE_LOCATION
            project_url = git_project_url_base.format(project)
            anchor = GIT_ANCHOR

        repos_list[project] = {
            "url": project_url,
            "url-pattern": {
                "base-url": code_url,
                "anchor": anchor,
                "ms-between-poll": poll * 1000
            }
        }

    return repos_list


def parse_arguments():
    """Return parsed command-line arguments."""
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    parser.add_argument('--gerrit', help='Gerrit address', default=DEFAULT_GERRIT)
    group.add_argument('--ssh', help='SSH information for Gerrit access: user, port', nargs=2)
    group.add_argument('--git', help='External git address. Does not support --ssh')
    parser.add_argument('--poll-interval', help='Repositories polling interval in seconds', type=int, default=DEFAULT_POLL)

    return parser.parse_args()


def main():
    """Main entry point for the script."""
    arguments = parse_arguments()

    projects = get_projects_list(arguments.gerrit)
    repos = create_repos_list(projects, arguments.gerrit, arguments.ssh, arguments.git, arguments.poll_interval)
    config = {
        "max-concurrent-indexers": 2,
        "dbpath": "data",
        "health-check-uri": "/healthz",
        "repos": repos
    }
    print(json.dumps(config, sort_keys=True, indent=4, separators=(',', ': ')))


if __name__ == '__main__':
    sys.exit(main())
