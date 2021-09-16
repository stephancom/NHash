# NHash

This gem solves the common need for an n-dimensional hash that is pre-initialized.

In addition, it offers a novel means of slicing through N-dimensional hashes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'NHash'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install NHash

## Usage

Initialize NHash with a number of dimensions, 3 by default.  Values may then be set/retrieved using a list of keys, like so:
```ruby
> n = NHash.new(3)
> n[1, 2, 3] = :foo
> n[:a, :b, :c] = :bar
> n.to_h
{1 => { 2 => { 3 => :foo}}, a: { b: { c: :bar }}}
```

Keys may be of any type, but are converted to symbols internally when possible for indifferent access
```ruby
> n['a', :b, 'd'] = :baz
> n.to_h
{1 => { 2 => { 3 => :foo}}, a: { b: { c: :bar, d: :baz }}}
```

### pre-initialization

It is not uncommon to see this pattern for a hash of hashes:
```ruby
newhash = {}
things.each do |thing|
    newhash[thing.name] = {}
    thing.otherthing.each do |otherthing|
        newhash[thing.name][otherthing.name] = otherthing.result
    end
end
```
NHash allows:
```ruby
newhash = NHash.new(2)
things.each do |thing|
    thing.otherthing.each do |otherthing|
        newhash[thing.name, otherthing.name] = otherthing.result
    end
end
```

### slicing

Let's say we have a list of airport flights and their count of passengers

```ruby
flight = NHash.new
flight[:ord, :lax] = 200
flight[:ord, :jfk] = 150
flight[:atl, :jfk] = 175
```

Find all flights from :ord like so:
```ruby
> flight[:ord, nil]
{lax: 200, jfk: 150}
```
or to JFK as:
```ruby
> flight[nil, :jfk]
{ord: 150, atl: 175}
```
too few parameters assumes the remainder are `nil`
```ruby
> flight[:atl]
{jfk: 175}
> flight[:lax]
{}
```

slicing may only be used for reading, not assignment.  In effect, any given parameter removes that level from the heirarchy

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stephancom/NHash. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/stephancom/NHash/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NHash project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stephancom/NHash/blob/master/CODE_OF_CONDUCT.md).
