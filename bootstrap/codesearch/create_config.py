#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Create configuration for code search."""

import json
import urllib.request
import sys

ONAP_GERRIT = "https://gerrit.onap.org/r"
ONAP_CGIT = "https://git.onap.org"
API_PROJECTS = "/projects/"

MAGIC_PREFIX = ")]}'"


def get_projects_list():
    """Request list of all available projects from ONAP Gerrit."""
    resp = urllib.request.urlopen(ONAP_GERRIT + API_PROJECTS)
    resp_body = resp.read()

    no_magic = resp_body[len(MAGIC_PREFIX):]
    decoded = no_magic.decode("utf-8")
    projects = json.loads(decoded)

    return projects.keys()


def create_repos_list(projects):
    """Create a map of all projects to their repositories' URLs."""
    repos_list = {}
    for project in projects:
        repos_list[project] = {
            "url": "{}/{}".format(ONAP_CGIT, project),
            "url-pattern": {
                "base-url": "{url}/tree/{path}{anchor}",
                "anchor": "#n{line}"
            }
        }

    return repos_list


def main():
    """Main entry point for the script."""
    repos = create_repos_list(get_projects_list())
    config = {
        "max-concurrent-indexers": 2,
        "dbpath": "data",
        "health-check-uri": "/healthz",
        "repos": repos
    }
    print(json.dumps(config, sort_keys=True, indent=4, separators=(',', ': ')))


if __name__ == '__main__':
    sys.exit(main())
