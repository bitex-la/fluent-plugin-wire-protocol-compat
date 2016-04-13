module Fluent
  class TestOutput < Output
    Plugin.register_output('test', self)
    @@emitted = [ ]

    URI = "druby://:#{MiscHelpers.unused_port}"
    DRb.start_service(URI, @@emitted)

    def configure(conf)
      super
      @remote = DRbObject.new(nil, URI)
    end

    def emit(tag, es, chain)
      chain.next
      events = es.collect.to_a
      @remote << [ tag, events ]
    end

    def shutdown
      super
      @remote.clear
    end

    def self.emitted
      @@emitted
    end
  end
end
