# Bugzilla

[![Build
Status](https://travis-ci.org/vpereira/bugzilla.svg?branch=master)](https://travis-ci.org/vpereira/bugzilla)
[![Maintainability](https://api.codeclimate.com/v1/badges/36383c479e2c8a9e8182/maintainability)](https://codeclimate.com/github/vpereira/bugzilla/maintainability)
[![Test
Coverage](https://api.codeclimate.com/v1/badges/36383c479e2c8a9e8182/test_coverage)](https://codeclimate.com/github/vpereira/bugzilla/test_coverage)

A revamp from the ruby-bugzilla. Code refactoring and added specs are the main
differences. The bzconsole app, was moved as well for its own gem, named ```bzconsole```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bugzilla'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bugzilla

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To jump in the development docker container:

```docker run -v "$PWD:/root/bugzilla" -ti bugzilla ./entrypoint.sh```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bugzilla. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bugzilla project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/bugzilla/blob/master/CODE_OF_CONDUCT.md).
