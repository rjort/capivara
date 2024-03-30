module Commands
  module Handlers
    module CommandData
      attr_reader :templates_path,
                  :schema_type,
                  :project_name,
                  :project_path,
                  :json_path,
                  :projet_root_path

      def self.set_template_type(type)
        @@schema_type = type
      end

      def self.generate_option(opt)
        @@generate_opt_flag, @@generate_flag_arg = opt
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
          generate_flag: @@generate_opt_flag,
          generate_arg: @@generate_flag_arg
        }
      end

      def data_config
        @project_path = Dir.pwd
        @project_name = File.basename(Dir.pwd)
        @json_path    = "#{@project_path}/capivara.json"

        {
          project_path: @project_path,
          project_name: @project_name,
          json_path: @json_path,
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