# Jeera
=====

JIRA is an intuitive command line interface using [JIRA]()'s REST API. It can handle your issues.

Jeera is built with [thor]().

Jeera currently assumes a hosted instance of JIRA.


For a list of commands:
```
jeera help
```

## Config

Jeera looks for a *.jeera* dotfile in your home directory.

```
# As in https://<my_jira_name>.jira.com
jira_subdomain: ''
default_user: 'short_jira_name'
password: ''
default_project: 'WEB'
```

## TODO

* Map statuses, types, etc. & store locally
* Config dialog
* "Use" issue. Hold indiv issue reference for sequential commands.
* Launch editor/vim for comment editing
* OAuth
