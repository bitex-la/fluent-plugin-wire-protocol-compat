# Fluent::WireProtocolCompatInput

This plugin makes the wire protocol for [in\_udp](http://docs.fluentd.org/articles/in_udp) and [in\_tcp](http://docs.fluentd.org/articles/in_tcp) compatible with [in\_forward](http://docs.fluentd.org/articles/in_forward#protocol)'s.

Note: You need to install [fluent-plugin-msgpack-parser](https://rubygems.org/gems/fluent-plugin-msgpack-parser) to add [msgpack](http://msgpack.org/) support for `in_udp` and `in_tcp`.

## Installation

Please check Fluentd's [plugin management docs](http://docs.fluentd.org/articles/plugin-management)

## Usage
### Example configuration
```
<source>
  type wire_protocol_compat
  <input>
    type udp
    port 12201
    bind 127.0.0.1
    format json
    tag some_tag
  </input>
</source>
```

## Contributing

1. Fork it ( https://github.com/bitex-la/fluent-plugin-wire-protocol-compat/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## TODO
* Additional formats specs
* Extract rspec-fluentd gem
