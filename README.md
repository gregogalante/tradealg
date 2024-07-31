# Tradealg

Trading Algorithm in pure Ruby.

## Usage

```ruby
require 'tradealg'

operations = [
  { type: :deposit, value: 100.0, timestamp: Time.new(2000, 1, 1, 0, 0, 0) },
  { type: :deposit, value: 50.0, timestamp: Time.new(2000, 1, 2, 0, 0, 0) },
  { type: :deposit, value: 25.0, timestamp: Time.new(2000, 1, 3, 0, 0, 0) },
  { type: :buy, value: 10.0, timestamp: Time.new(2000, 1, 4, 0, 0, 0) },
  { type: :sell, value: 10.0, timestamp: Time.new(2000, 1, 5, 0, 0, 0) },
  { type: :buy, value: -10.0, timestamp: Time.new(2000, 1, 6, 0, 0, 0) },
  { type: :sell, value: -10.0, timestamp: Time.new(2000, 1, 7, 0, 0, 0) },
]

tradealg = Tradealg.new(operations)

puts tradealg.balance_at(Time.now)
```

## Test gem

```bash
gem install rake
gem install rspec
rake test
```
