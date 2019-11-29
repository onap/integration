=====================================================
 ONAP Integration > Bootstrap > Vagrant Minimal ONAP
=====================================================

This directory contains a set of Vagrant scripts that will automatically set up:

- Devstack,
- RKE-based Kubernetes cluster,
- Operator's machine with configured tools (kubectl, helm).

This is intended to show a beginning ONAP operator how to set up and configure an environment that
can successfully deploy minimal ONAP instance from scratch. Its main purpose are ONAP demos and
proofs of concepts. It is not intended to be used as a production ONAP environment.

NOTE: the Devstack instance is NOT SECURED, with default credentials:

+-------+----------------+
| User  | Password       |
+-------+----------------+
| admin | default123456! |
+-------+----------------+
| demo  | default123456! |
+-------+----------------+
