# Redmine Accounting plugin

Plugin which adds the functionality of tracking changes in project.

Observed changes include:

* project status
* project name
* added/deleted members with a certain role (configurable)
* one custom field value (configurable)

# Requirements

Developed and tested on Redmine 2.5.1.

# Installation

1. Go to your Redmine installation's plugins/ directory.
2. `git clone http://github.com/efigence/redmine_accounting`
3. Go back to root directory.
4. `rake redmine:plugins:migrate RAILS_ENV=production`
5. Restart Redmine.

# Configuration

Visit Administration -> Plugins. Afterwards, click on `Configure` link next to the plugin name.

Here you can define:

* role title, which will be observed in project history entires
* custom field, which will observed
* redmine groups, which will have access to the `accounting` page

# Usage

To see the history page, simply click on `accounting` link located on top menu.
