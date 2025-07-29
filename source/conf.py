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
]

# the current base URL of your documentation.
html_baseurl = 'https://skycluster.io'
# defaul is {lang}{version}{link}, where {lang} and {version} get set by language and version
sitemap_url_scheme = "{lang}{version}{link}"
sitemap_excludes = ['index.html', 'search.html', 'genindex.html']
html_title = 'SkyCluster'

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

html_favicon = 'en/latest/_static/imgs/skycluster-favicon.png'
html_logo = 'en/latest/_static/imgs/skycluster-favicon.png'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_theme = 'alabaster'
html_theme = 'pydata_sphinx_theme'
html_static_path = ['en/latest/_static']
html_extra_path = ['CNAME', 'skycluster']

# Add this to include Table of Contents in each page
html_sidebars = {
    "**": ["sidebar-nav-bs.html"]
}

# Add title customization using html_theme_options
html_theme_options = {
    # This will affect how the titles are rendered
    'collapse_navigation': False,
    "secondary_sidebar_items": ["page-toc"],
    "show_nav_level": 4,
    "logo": {
        "text": "SkyCluster",
        "image_light": "en/latest/_static/imgs/skycluster-favicon.png",
        "image_dark": "en/latest/_static/imgs/skycluster-favicon.png",
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