# Parallelixir

A library which delegates Ruby background job processing to Elixir.

This library uses Redis to enqueue jobs, and notify Elixir when they're enqueued, so that they
can be runned through Erlang ports.

WARNING: This project is experimental, so don't use it in production!

## Installation

First, you will need to have Elixir installed. Follow the instructions in the [official
guide](https://elixir-lang.org/install.html) to install it.

Add this line to your application's Gemfile:

```ruby
gem 'parallelixir'
```

Add `parallelixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:parallelixir, git: "https://github.com/mansakondo/parallelixir"}
  ]
end
```
Then fetch the dependencies:

    $ bundle install
    $ mix deps.get

## Usage

Include the `Parallelixir::Job` mixin in your classes:
```ruby
class SomeJob
  include Parallelixir::Job

  def perform(*args)
    # do some work
  end
end
```

Run this in another terminal window to start the Parallelixir server:
    
    $ mix run

Or add this command in a `Procfile` if you're using Foreman.

# Configuration

You can configure Parallelixir using `Parallelixir.configure`:
```ruby
Parallelixir.configure do |config|
  config.redis = { ... } # or ConnectionPool.new(...)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/parallelixir.