from docs_conf.conf import *

branch = 'latest'
master_doc = 'index'

linkcheck_ignore = [
    'http://localhost',
]

intersphinx_mapping = {}

html_last_updated_fmt = '%d-%b-%y %H:%M'

exclude_patterns = ['onap-integration-ci.rst', 'release-notes.rst',
                    'bootstrap/codesearch/README.rst']

def setup(app):
    app.add_stylesheet("css/ribbon_onap.css")
