# GOV.UK Rails Application Template

A template for building a skeleton Rails 4 application ready for use on the
GOV.UK stack.

## How to use

```shell
RBENV_VERSION=2.3.0 rails new APP_NAME --skip-javascript --skip-test-unit --skip-spring -m govuk-rails-app-template/template.rb
```

## What it will do

1. Build a new rails 4 application
2. Install rspec/rails and other useful gems for testing, and remove test/unit
3. Add a README.md and LICENSE file
4. Add a route for a /healthcheck endpoint
5. Enable JSON-formatted logging
6. Add scripts for jenkins master and branch builds
7. Add a .ruby-version file
8. Set up coverage reporting with simplecov
9. Set up airbrake for errbit-based error reporting
10. Add govuk-lint and run it in diff mode as part of the jenkins script

Further details on setting up a new Rails application on the GOV.UK stack can be
found over on the [Ops Manual](https://github.gds/pages/gds/opsmanual/infrastructure/howto/setting-up-new-rails-app.html).

## Licence

[MIT License](LICENSE)
