require 'fluent/input'
require 'fluent/plugin'

module Fluent
  class WireProtocolCompatInput < Input
    Plugin.register_input('wire_protocol_compat', self)
    def configure(conf)
      super

      @inputs = [ ]
      config.each_element('input') do |input_config|
        type = input_config.delete('@type')
        next unless [ 'udp', 'tcp' ].include? type
        base_input = Plugin.new_input(type).class
        input_klass = Class.new(base_input) do
          include WireProtocolCompatInput::SocketUtilBaseInputMethods
        end
        input = input_klass.new
        input.configure(input_config)
        if input.format == 'json'
          parser_klass = Class.new(Fluent::TextParser::JSONParser) do
            include WireProtocolCompatInput::JSONParserMethods
          end
          input.instance_eval do
            @parser = parser_klass.new
            @parser.configure(@config)
          end
        end
        @inputs << input
      end
    end

    def start
      super
      @inputs.each(&:start)
    end

    def shutdown
      super
      @inputs.each(&:shutdown)
    end

    module JSONParserMethods
      def normalize_hash(record)
        value = @keep_time_key ? record[@time_key] : record.delete(@time_key)
        if value
          if @time_format
            time = @mutex.synchronize { @time_parser.parse(value) }
          else
            begin
              time = value.to_i
            rescue => e
              raise ParserError, "invalid time value: value = #{value}, error_class = #{e.class.name}, error = #{e.message}"
            end
          end
        else
          if @estimate_current_event
            time = Engine.now
          else
            time = nil
          end
        end
        [ time, record ]
      end

      def parse(text)
        parsed = @load_proc.call(text)
        case parsed
        when Hash
          normalized = normalize_hash(parsed)
        when Array
          normalized = parsed
        end
        yield *normalized
      end
    end

    module SocketUtilBaseInputMethods
      def on_message(msg, addr)
        @parser.parse(msg) do |*parsed|
          case parsed[0]
          when String
            tag, time, record = parsed
            records = time.is_a?(Array) ? time : [ [ time, record ] ]
          when Integer
            tag = @tag
            records = [ parsed ]
          end

          time, record = records.first
          unless time && record
            log.warn "pattern not match: #{msg.inspect}"
            return
          end

          es = MultiEventStream.new
          records.each do |time, record|
            record[@source_host_key] = addr[3] if @source_host_key
            es.add(time, record)
          end
          router.emit_stream(tag, es)
        end
      rescue => e
        log.error msg.dump, :error => e, :error_class => e.class, :host => addr[3]
        log.error_backtrace
      end
    end
  end
end
