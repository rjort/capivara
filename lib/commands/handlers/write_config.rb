module Commands
  module Handlers
    class WriteConfigs
      include CommandData

      def write_configs_json_default(config_path)
        File.open(config_path, 'w') do |file|
          file.write(JSON.pretty_generate(content_buffer))
          file.close
        end
      end
    end
  end
end
