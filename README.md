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
# Hash
h.dig(:some, "nested", :hash)   # foo

ph = PropertyString(h)
ph["some.nested.hash"]

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

# Ignore
ps = PropertyString.new(product, :raise_if_method_missing => false)
ps["company.does_not_exist!"] # nil

# Fetching
ps.fetch("posts.9999", "your default") # shaw
ps.fetch("posts.9999") { |key| "some_default_for_#{key}" }
```

## See Also

- [PropertyHash](https://github.com/sshaw/property_hash) - Access a nested Ruby Hash using Java-style properties as keys.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sshaw/property_string.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
