# Gracefully

[![Build Status](https://travis-ci.org/crowdworks/gracefully.svg?branch=master)](https://travis-ci.org/crowdworks/gracefully)
[![Coverage Status](https://coveralls.io/repos/crowdworks/gracefully/badge.png?branch=master)](https://coveralls.io/r/crowdworks/gracefully?branch=master)
[![Code Climate](https://codeclimate.com/github/crowdworks/gracefully/badges/gpa.svg)](https://codeclimate.com/github/crowdworks/gracefully)

ensures features gracefully degrade based on error rate or turnaround time.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gracefully'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gracefully

## Usage

Set up one instance per feature which is gracefully degradable.

```ruby
the_feature = Gracefully.
                degradable_command(retries: 0, allowed_failures: 1) do |a|
                  if rand < 0.5
                    'foo'
                  else
                    raise 'err1'
                  end
                end.
                fallback_to(retries: 2) do |a|
                  if rand < 0.5
                    'bar'
                  else
                    raise 'err2'
                  end
                end

10.times.map do
  begin
    the_feature.call
  rescue => e
    e.message
  end
end
#=> ["bar", "bar", "bar", "bar", "bar", "bar", "bar", "bar", "bar", "Tried to get the value of a failure"]
```

See `spec/gracefully_spec.rb` for more usages.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gracefully/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
