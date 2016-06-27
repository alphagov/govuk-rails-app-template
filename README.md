# GOV.UK Rails Application Template

A template for building a skeleton Rails 4 application ready for use on the
GOV.UK stack.

## Usage

There are four templates available, one for each category of application on GOV.UK.

Generally they can be invoked by updating your `rails` gem, switching into your
GOV.UK code directory (`/var/govuk` on the VM) and running:

```shell
./govuk-rails-app-template/bin/install.sh app-name (api|frontend|admin|publishing)
```

You may find that the version of Rails you have doesn't match the one being generated for the app,
in which case you should either install the matching version or update `templates/Gemfile`
to the correct version.

App names must be lowercase alpha plus hyphens, and valid values for `{template}` are:
- api
- admin
- publishing
- frontend

So a valid example might be:

```shell
./govuk-rails-app-template/bin/install.sh some-fancy-api api
```

Admin and publishing apps are similar, except that publishing apps include integrations
to the publishing API.

See the admin, api, frontend, and publishing classes in `lib` to see what this
will do.

Further details on setting up a new Rails application on the GOV.UK stack can be
found over on the [Ops Manual](https://github.gds/pages/gds/opsmanual/infrastructure/howto/setting-up-new-rails-app.html).

## Licence

[MIT License](LICENSE)
