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

GITWEB_ANCHOR = "#l{line}"
GIT_ANCHOR = "#n{line}"


def get_projects_list(gerrit):
    """Request list of all available projects from ONAP Gerrit."""
    resp = urllib.request.urlopen("https://{}{}{}".format(gerrit, API_PREFIX, API_PROJECTS))
    resp_body = resp.read()

    no_magic = resp_body[len(MAGIC_PREFIX):]
    decoded = no_magic.decode("utf-8")
    projects = json.loads(decoded)

    return projects.keys()


def create_repos_list(projects, gerrit, ssh, git):
    """Create a map of all projects to their repositories' URLs."""
    gerrit_url = "https://{}{}".format(gerrit, API_PREFIX)
    gerrit_project_url = "{}/{{}}.git".format(gerrit_url)
    gitweb_code_url = "{}/gitweb?p={{}}.git;hb=HEAD;a=blob;f={{path}}{{anchor}}".format(gerrit_url)

    repos_list = {}
    for project in projects:
        project_url = gerrit_project_url.format(project)
        code_url = gitweb_code_url.format(project)
        anchor = GITWEB_ANCHOR

        if ssh and len(ssh) == 2:
            user, port = ssh[0], ssh[1]
            project_url = "ssh://{}@{}:{}/{}.git".format(user, gerrit, port, project)
        if git:
            code_url = "https://{}/{}/tree/{{path}}{{anchor}}".format(git, project)
            anchor = GIT_ANCHOR

        repos_list[project] = {
            "url": project_url,
            "url-pattern": {
                "base-url": code_url,
                "anchor": anchor
            }
        }

    return repos_list


def parse_arguments():
    """Return parsed command-line arguments."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gerrit', help='Gerrit address', default=DEFAULT_GERRIT)
    parser.add_argument('--ssh', help='SSH information: user, port', nargs=2)
    parser.add_argument('--git', help='external git address')

    return parser.parse_args()


def main():
    """Main entry point for the script."""
    arguments = parse_arguments()

    projects = get_projects_list(arguments.gerrit)
    repos = create_repos_list(projects, arguments.gerrit, arguments.ssh, arguments.git)
    config = {
        "max-concurrent-indexers": 2,
        "dbpath": "data",
        "health-check-uri": "/healthz",
        "repos": repos
    }
    print(json.dumps(config, sort_keys=True, indent=4, separators=(',', ': ')))


if __name__ == '__main__':
    sys.exit(main())
