# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'SkyCluster'
copyright = '2024, Ehsan Etesami'
author = 'Ehsan Etesami'

language = 'en'
version = '0.1.0'
release = '0.1.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.githubpages',
    'sphinx.ext.ifconfig',
    'sphinx.ext.graphviz',
    'sphinx.ext.extlinks',
    'sphinx.ext.imgconverter',
    'sphinx_copybutton',
    'sphinx_reredirects',
    'sphinx_sitemap',
    'sphinx_tabs.tabs',
    'sphinx_multiversion'
]

sphinx_tabs_disable_tab_closing = True

# the current base URL of your documentation.
html_baseurl = 'https://skycluster.io'
# defaul is {lang}{version}{link}, where {lang} and {version} get set by language and version
sitemap_url_scheme = "{lang}{version}{link}"
sitemap_excludes = ['index.html', 'search.html', 'genindex.html']
html_title = 'SkyCluster Docs'

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

html_favicon = 'en/_static/imgs/skycluster-logo1-enhanced-favicon.png'
html_logo = 'en/_static/imgs/skycluster-logo1-enhanced-icon-small.png'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_theme = 'alabaster'
html_theme = 'pydata_sphinx_theme'
html_static_path = ['en/_static']
html_extra_path = ['CNAME', 'skycluster']

# Add this to include Table of Contents in each page
html_sidebars = {
    "**": ["sidebar-nav-bs.html", "versioning.html"]
}

# Add title customization using html_theme_options
html_theme_options = {
    # This will affect how the titles are rendered
    'collapse_navigation': False,
    "secondary_sidebar_items": ["page-toc"],
    "show_nav_level": 4,
    "logo": {
        "text": "SkyCluster",
        "image_light": "en/_static/imgs/skycluster-logo1-enhanced-icon-small.png",
        "image_dark": "en/_static/imgs/skycluster-logo1-enhanced-dark-icon-small.png",
    },
    "icon_links_label": "Quick Links",
    "icon_links": [
        {
            "name": "GitHub",         
            "url": "https://github.com/etesami/skycluster",  # required
            "icon": "fa-brands fa-square-github",
            "type": "fontawesome",
        },
    ],
    "footer_start": ["copyright", "last-updated"],
    "footer_end": [],
    "content_footer_items": ["last-updated"],
    "back_to_top_button": True,
}


# redirects = {
#      "docs/user-guide/index": "/docs/user-guide/installation"
# }

def setup(app):
    app.add_css_file('css/custom.css')
    app.add_js_file('https://code.jquery.com/jquery-3.6.0.min.js')
    
    
    
smv_branch_whitelist = '^(dev|latest)$'