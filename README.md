# Gem::Try

Gem subcommand to fire up an IRB-session with gems loaded:

```shell
$ gem try activerecord sqlite3
Resolving dependencies...
irb(main):001> ActiveRecord::Base.establish_connection(adapter: :sqlite3, database: ':memory:')
irb(main):002> ActiveRecord::Base.connection.select_all('select 1')
```

## Installation

```shell
$ gem install gem-try
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eval/gem-try.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
