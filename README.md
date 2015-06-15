# GOV.UK Rails Application Template

A template for building a skeleton Rails 4 application ready for use on the
GOV.UK stack.

## How to use

```shell
RBENV_VERSION=2.2.2 rails new APP_NAME --skip-javascript --skip-test-unit --skip-spring -m govuk-rails-app-template/template.rb
```

## What it will do

1. Build a new rails 4 application

1. Install rspec/rails for testing and remove test/unit

2. Add a template README.md and LICENSE file

3. Add a route for a /healthcheck endpoint

4. Enable JSON-formatted logging

5. Add scripts for jenkins master and branch builds

6. Add a .ruby-version file

7. Set up coverage reporting with simplecov


Further details on setting up a new Rails application on the GOV.UK stack can be
found over on the [Ops Manual](https://github.gds/pages/gds/opsmanual/infrastructure/howto/setting-up-new-rails-app.html).

## Licence

[MIT License](LICENSE)
