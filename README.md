# PropertyString

![PropertyString CI Status](https://github.com/sshaw/property_string/workflows/CI/badge.svg "PropertyString CI Status")

Use Java-style property notation to execute method call chains on an object.

## Installation

Install the gem and add to the application's Gemfile by executing:

    bundle add property_string

If bundler is not being used to manage dependencies, install the gem by executing:

    gem install property_string

## Usage

```rb
# Object call chain
product.company.name            # bar

ps = PropertyString.new(product)
ps["company.name"]              # bar

# Object call chain with Array-like object
user.posts[0].replied_to.name   # sshaw

ps = PropertyString.new(user)
ps["posts.0.replied_to.name"]       # sshaw

# Method does not exist
ps = PropertyString.new(product)
ps["company.does_not_exist!"] # NoMethodError

# Can work with a Hash
h.dig(:some, "nested", :hash)   # foo

ps = PropertyString.new(h)
ps["some.nested.hash"]

# Or an Array
a[0][0][0]

ps = PropertyString.new(a)
ps["0.0.0"]

# Fetching
ps.fetch("posts.9999", "your default")
ps.fetch("posts.9999") { |key| "some_default_for_#{key}" }
```

### Ignore `NoMethodError` for Unknown Properties

```rb
ps = PropertyString.new(product, :raise_if_method_missing => false)
ps["company.does_not_exist!"] # nil
```

### Restrict Methods That Can Be Called

```rb
ps = PropertyString.new(product, :whitelist => { Product => %w[company], Company => %w[name] })
ps["id"] # PropertyString::MethodNotAllowed
ps["company.id"] # PropertyString::MethodNotAllowed
```

Currently does not work when a superclass is whitelisted but trivial to add.

## See Also

- [PropertyHash](https://github.com/sshaw/property_hash) - Access a nested Ruby Hash using Java-style properties as keys.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sshaw/property_string.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
