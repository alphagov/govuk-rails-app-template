#!/bin/sh

die() {
  echo >&2 "$@"
  echo "\nUsage: ./govuk-rails-app-template/bin/install.sh app-name (api|frontend|admin|publishing)"
  exit 1
}

[ "$#" -eq 2 ] || die "2 arguments required, $# provided"
echo $1 | grep -E -q '^[a-z-]+$' || die "Application name must be lowercase with hyphens"
echo $2 | grep -E -q '^(api|frontend|admin|publishing)$' || die "Application type must be api, frontend, admin, or publishing"

app_name=$1
template=$2

echo "Checking Rails version.."

expected_rails=$(sed -n 's/.*rails", "\(.*\)"/\1/p' govuk-rails-app-template/templates/Gemfile)
actual_rails=$(rails -v | sed -n 's/Rails \(.*\)/\1/p')

if [ "$expected_rails" == "$actual_rails" ]; then
  echo "Rails versions match, using $actual_rails"
else
  echo "You're using an unexpected Rails version, either install version $expected_rails or upgrade the template to $actual_rails."
fi

set RBENV_VERSION=2.4.4
rails new $app_name --skip-javascript --skip-test-unit --skip-bundle --skip-spring -m govuk-rails-app-template/$template.rb
