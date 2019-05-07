#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Create configuration for code search."""

import argparse
import json
import urllib.request
import sys

DEFAULT_GERRIT="https://gerrit.onap.org/r"
DEFAULT_GIT="https://git.onap.org"
API_PROJECTS="/projects/"

MAGIC_PREFIX=")]}'"

def get_projects_list(gerrit):
    """Request list of all available projects from ONAP Gerrit."""
    resp = urllib.request.urlopen(gerrit + API_PROJECTS)
    resp_body = resp.read()

    no_magic = resp_body[len(MAGIC_PREFIX):]
    decoded = no_magic.decode("utf-8")
    projects = json.loads(decoded)

    return projects.keys()


def create_repos_list(projects, git):
    """Create a map of all projects to their repositories' URLs."""
    repos_list = {}
    for p in projects:
        repos_list[p] = {
            "url": "{}/{}".format(git, p),
            "url-pattern": {
                "base-url": "{url}/tree/{path}{anchor}",
                "anchor": "#n{line}"
            }
        }

    return repos_list


def parse_arguments():
    """Return parsed command-line arguments."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gerrit', help='Gerrit address', default=DEFAULT_GERRIT)
    parser.add_argument('--git', help='git address', default=DEFAULT_GIT)

    return parser.parse_args()


def main():
    """Main entry point for the script."""
    arguments = parse_arguments()

    repos = create_repos_list(get_projects_list(arguments.gerrit), arguments.git)
    config = {
        "max-concurrent-indexers": 2,
        "dbpath": "data",
        "health-check-uri": "/healthz",
        "repos": repos
    }
    print(json.dumps(config, sort_keys=True, indent=4, separators=(',', ': ')))


if '__main__' == __name__:
    sys.exit(main())
