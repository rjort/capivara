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

      def data_generate
        @project_path = Dir.pwd
        @json_path    = "#{@project_path}/capivara.json"
        @features_path = JSON.parse(File.read(@json_path))['path']

        {
          # TODO: para pages_path, validar caminho de acordo com o template
          # o template de api usa => /services/nome_da_api.rb
          pages_path: File.join(@features_path, '/page_objects/pages'),
          steps_path: File.join(@features_path, '/step_definitions'),
          section_path: File.join(@features_path, '/page_objects/sections'),
          gherkin_path: File.join(@features_path, '/specs'),
          json_path: @json_path,
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