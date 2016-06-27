# GOV.UK Rails Application Template

A template for building a skeleton Rails 4 application ready for use on the
GOV.UK stack.

## Usage

There are four templates available, one for each category of application on GOV.UK.

Generally they can be invoked by updating your `rails` gem and running:

```shell
RBENV_VERSION=2.3.0 rails new APP_NAME --skip-javascript --skip-test-unit --skip-bundle --skip-spring -m govuk-rails-app-template/{template}.rb
```

Valid values for `{template}` are:
- api
- admin
- publishing
- frontend

Admin and publishing apps are similar, except that publishing apps include integrations
to the publishing API.

See the admin, api, frontend, and publishing classes in `lib` to see what this
will do.

Further details on setting up a new Rails application on the GOV.UK stack can be
found over on the [Ops Manual](https://github.gds/pages/gds/opsmanual/infrastructure/howto/setting-up-new-rails-app.html).

## Licence

[MIT License](LICENSE)
