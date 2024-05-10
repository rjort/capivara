module Commands
  module Handlers
    class WriteConfigs
      include CommandData

      def write_configs_json_default(config_path)
        if File.exist?(config_path)
          File.open(config_path, 'w') do |file|
            file.write(JSON.pretty_generate(content_data_json))
            file.close
          end
        else
          exit -1
        end
      end

      private

      def content_data_json
        data_config_json
      end
    end
  end
end