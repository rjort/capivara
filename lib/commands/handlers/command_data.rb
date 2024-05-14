module Commands
  module Handlers
    module CommandData
      attr_reader :templates_path,
                  :schema_type,
                  :project_name,
                  :project_path,
                  :json_path,
                  :projet_root_path,
                  :flag_option,
                  :flag_value
                  
      def self.set_config_file_name(name)
        @@config_file_name = name
      end

      def self.set_template_type(type)
        @@schema_type = type
      end

      def self.flag_options(opt)
        @@flag, @@value = opt
        @flag_option  = @@flag
        @flag_value   = @@value
      end

      def create_config_json(data)
        @@configs = data
      end

      def data_config_json
        @@configs
      end

      def get_config_file_name
        @@config_file_name
      end

      def data_generate
        {
          generate_flag: @@flag,
          generate_arg: @@value
        }
      end

      def data_config
        @project_root_path = Dir.pwd
        @project_name = File.basename(Dir.pwd)
        @features_path = File.join(@project_root_path, 'features')
        @json_path    = File.join(@project_root_path, 'capivara.json')

        {
          project_name: @project_name,
          project_root_path: @project_root_path,
          features_path: @features_path,
          json_path: @json_path
        }
      end

      def data_create
        @templates_path = File.expand_path(File.join(File.dirname(__FILE__), '../../templates/'))
        @schema_type    = @@schema_type

        {
          templates_path: @templates_path,
          schema_type: @schema_type,
          project_name: '',
          project_root_path: ''
        }
      end
    end
  end
end