
[![Build Status](https://travis-ci.org/anvox/tiny_decorator.svg?branch=master)](https://travis-ci.org/anvox/tiny_decorator)

# TinyDecorator

The world of ruby decorator is dominated by `draper`, I use it all the time.
But when project grows and we chase the dealine, the flexible and easily of `draper` make us keep abusing it. Now, when using a decorated model we dont know which method/attribute are define in which decorator, which decorators depend on which ones.
`tiny_decorator` aims to separate decoration logic into different decorators, and centralize logic to determine which decorators are used. It isn't built to replace `draper` as it just solve our internal problem of abusing `draper`, it's better if you using `draper` wisely instead `tiny_decorator`

But if you're interesting in this gem, every contributes are welcome.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tiny_decorator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tiny_decorator

## Usage

Model decorated by 1 single decorator
```ruby
  class NewDecorator < TinyDecorator::SingleDecorator
    def new_method
      'decorated'
    end
  end

  NewDecorator.decorate(Object.new).new_method # 'decorated'
  NewDecorator.decorate_collection([Object.new, Object.new])[1].new_method # 'decorated'
```

Model decorate by more than 1 decorators
```ruby
  class NewDecorator2
    extend TinyDecorator::CompositeDecorator

    decorated_by :default, 'DefaultDecorator'

    decorated_by :nil, ->(record) { record.nil? ? 'NilDecorator' : 'DefaultDecorator' }
    decorated_by :nil, ->(record, context) { record.in(context).nil? ? 'NilDecorator' : 'DefaultDecorator' }
  end
```

And use it
```ruby
context = { current_user: user }
#
NewDecorator.decorate(model)
NewDecorator.decorate(model, context)
# OR
NewDecorator.decorate_collection(models)
NewDecorator.decorate_collection(models, context)

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tiny_decorator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TinyDecorator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tiny_decorator/blob/master/CODE_OF_CONDUCT.md).
