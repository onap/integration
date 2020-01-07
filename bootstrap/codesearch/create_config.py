#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Create configuration for code search."""

import argparse
import json
import urllib.request
import sys

DEFAULT_GERRIT = "https://gerrit.onap.org/r"
DEFAULT_GIT = "https://git.onap.org"
API_PROJECTS = "/projects/"

MAGIC_PREFIX = ")]}'"

GITWEB_ANCHOR = "#l{line}"
GIT_ANCHOR = "#n{line}"


def get_projects_list(gerrit):
    """Request list of all available projects from ONAP Gerrit."""
    resp = urllib.request.urlopen(gerrit + API_PROJECTS)
    resp_body = resp.read()

    no_magic = resp_body[len(MAGIC_PREFIX):]
    decoded = no_magic.decode("utf-8")
    projects = json.loads(decoded)

    return projects.keys()


def create_repos_list(projects, gitweb, git, gerrit):
    """Create a map of all projects to their repositories' URLs."""
    gerrit_project_url = "{}/{}.git"
    gitweb_code_url = "{}/gitweb?p={}.git;hb=HEAD;a=blob;f={{path}}{{anchor}}"

    git_project_url = "{}/{}"
    git_code_url = "{url}/tree/{path}{anchor}"

    repos_list = {}
    for project in projects:
        if gitweb:
            project_url = gerrit_project_url.format(gerrit, project)
            code_url = gitweb_code_url.format(gerrit, project)
            anchor = GITWEB_ANCHOR
        else:
            project_url = git_project_url.format(git, project)
            code_url = git_code_url
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
    access = parser.add_mutually_exclusive_group()
    access.add_argument('--gitweb', help='use Gerrit\'s gitweb (bool)', action='store_true')
    access.add_argument('--git', help='use external git (address)', default=DEFAULT_GIT)

    return parser.parse_args()


def main():
    """Main entry point for the script."""
    arguments = parse_arguments()

    projects = get_projects_list(arguments.gerrit)
    repos = create_repos_list(projects, arguments.gitweb, arguments.git, arguments.gerrit)
    config = {
        "max-concurrent-indexers": 2,
        "dbpath": "data",
        "health-check-uri": "/healthz",
        "repos": repos
    }
    print(json.dumps(config, sort_keys=True, indent=4, separators=(',', ': ')))


if __name__ == '__main__':
    sys.exit(main())
