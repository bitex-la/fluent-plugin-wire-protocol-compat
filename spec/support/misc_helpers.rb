module MiscHelpers
  def self.unused_port
    s = TCPServer.open(0)
    port = s.addr[1]
    s.close
    port
  end

  def unused_port
    MiscHelpers.unused_port
  end

  def start_supervisor(conf)
    @supervisor_pid = fork do
      supervisor = Fluent::Supervisor.new(plugin_dirs: [ ],
        libs: [ ], use_v1_config: false, supervise: false)
      supervisor.instance_eval {
        @conf = Fluent::Config.parse(conf, '(test)', '(test_dir)', false)
      }
      supervisor.send(:set_system_config)
      supervisor.send(:init_engine)
      supervisor.send(:install_main_process_signal_handlers)
      supervisor.send(:run_configure)
      supervisor.send(:run_engine)
    end
    sleep 0.1
  end

  def stop_supervisor
    return unless @supervisor_pid
    Process.kill('INT', @supervisor_pid)
    Process.waitpid(@supervisor_pid)
    @supervisor_pid = nil
  end

  def wait_until(options={})
    Timeout.timeout(options[:wait] || 5) do
      sleep(0.1) until return_value = yield
      return_value
    end
  end
end

RSpec.configuration.include MiscHelpers
