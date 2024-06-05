project = "onap"
release = "newdelhi"
version = "newdelhi"

author = "Open Network Automation Platform"
# yamllint disable-line rule:line-length
copyright = "ONAP. Licensed under Creative Commons Attribution 4.0 International License"

pygments_style = "sphinx"
html_theme = "sphinx_rtd_theme"
html_theme_options = {
  "style_nav_header_background": "white",
  "sticky_navigation": "False" }
html_logo = "_static/logo_onap_2017.png"
html_favicon = "_static/favicon.ico"
html_static_path = ["_static"]
html_show_sphinx = False

extensions = [
    'sphinx.ext.intersphinx',
    'sphinx.ext.graphviz',
    'sphinxcontrib.blockdiag',
    'sphinxcontrib.seqdiag',
    'sphinxcontrib.swaggerdoc',
    'sphinxcontrib.plantuml'
]

#
# Map to 'latest' if this file is used in 'latest' (master) 'doc' branch.
# Change to {releasename} after you have created the new 'doc' branch.
#

branch = 'latest'  #TO BE CHANGED TO newdelhi WHEN OOM & CLI BRANCH IS AVAILABLE

intersphinx_mapping = {}
doc_url = 'https://docs.onap.org/projects'
master_doc = 'index'

exclude_patterns = ['.tox']

spelling_word_list_filename='spelling_wordlist.txt'
spelling_lang = "en_GB"

#
# Example:
# intersphinx_mapping['onap-aai-aai-common'] = ('{}/onap-aai-aai-common/en/%s'.format(doc_url) % branch, None)
#
intersphinx_mapping = {}
intersphinx_mapping['onap-oom'] = ('{}/onap-oom/en/%s'.format(doc_url) % branch, None)
intersphinx_mapping['onap-cli'] = ('{}/onap-cli/en/%s'.format(doc_url) % branch, None)

html_last_updated_fmt = '%d-%b-%y %H:%M'

def setup(app):
    app.add_css_file("css/ribbon.css")

linkcheck_ignore = [
  r'http://localhost:\d+/'
  r'http://localhost:.*',
  r'http://CONSUL_SERVER_UI:30270/ui/#/dc1/services',
  r'https://.*h=frankfurt',
  r'http.*frankfurt.*',
  r'http.*simpledemo.onap.org.*',
  r'http://ANY_K8S_IP.*',
  r'http://so-monitoring:30224',
  r'http://SINK_IP_ADDRESS:667.*',
  r'http.*K8S_HOST:30227.*',
  r'http.*K8S_NODE_IP.*',
  r'http.*REPO_IP.*',
  r'http://team.onap.eu',
  r'https://tools.ietf.org/html/rfc8345'
]
