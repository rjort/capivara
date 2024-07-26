module Commands
  module Handlers
    module CommandData
      attr_reader :templates_path,
                  :schema_type,
                  :project_name,
                  :project_path,
                  :json_path,
                  :flag_option,
                  :flag_value,
                  :command,
                  :page_type,
                  :configs,
                  :data_schema_template

      def self.config_file_name(name)
        @@config_file_name = name
      end

      def self.template_type(type)
        @@schema_type = type
      end

      def self.flag_options(opt)
        @@flag, @@value = opt
        @flag_option  = @@flag
        @flag_value   = @@value
      end

      def last_command(cmd)
        @command = cmd
      end

      # Description:
      # Store the provide data in the @@configs variable in hash format
      # Arguments:
      # - data (Hash): A hash containing the data to be stored
      #
      # Usage Example:
      # Commands::Handlers::CommandData.merge_config_json({new_data1:'', new_data2:''})
      def merge_config_json(data)
        @configs.merge!(data)
      end

      def config_file_name
        @@config_file_name
      end

      # Return a hash with command flag and value
      #
      # (hash) => :flag, :arg
      def data_args_generate
        {
          flag: @@flag,
          arg: @@value
        }
      end

      def read_capivara_file(path = 'capivara.json')
        raise 'Settings file (capivara.json) not exist' unless File.exist?(path)

        JSON.parse(File.read(path))
      end

      def store_buffer(content)
        @@buffer = content
      end

      def content_buffer
        @@buffer
      end

      # Initialize initial data for command create
      #
      # Create the instance of two entities: @configs and @data_schema_template
      #
      # @configs: creates the hash structure for the configuration file (capivara.json)
      # @data_schema_template: contains the reading of the initialized template file
      def process_data_create
        @configs = config_schema_template
        @templates_path = File.expand_path(File.join(File.dirname(__FILE__), '../../templates/'))
        @schema_type    = @@schema_type

        search_template(@templates_path, @schema_type)
        file = File.join(@templates_path, @schema_type)
        load_template_file("#{file}.yml")

        @page_type = page_object_type_by_schema(@schema_type)

        @configs[:project_schema] = @schema_type

        store_buffer(@configs)
      end

      def process_data_config
        @project_root_path = Pathname.new(Dir.pwd)
        @project_name = @project_root_path.basename.to_s

        @configs = config_schema_template
        @configs[:project_root_path] = @project_name.to_s
        @configs[:project_name] = @project_name.capitalize
        @configs[:features_path] = 'features'
        @configs[:json_path] = 'capivara.json'
        @configs[:project_schema] = 'custom'

        store_buffer(@configs)
      end

      # Verify if the configuration file exist and if the necessary fields are included
      # Do not check if the fields are empty
      def process_validade_config_file(file_name)
        array_file = Dir.glob(file_name)
        raise 'Config file not exist' if array_file.empty?

        file_parsed = JSON.parse(File.read(file_name))
        raise 'Settings file is empty' if file_parsed.empty?

        check_capivara_file_fields(file_parsed)
      end

      private

      # Create a Capivara.json schema config
      def config_schema_template
        {
          project_root_path: '',
          project_name: '',
          features_path: '',
          json_path: '',
          project_schema: '',
          pages_path: '',
          steps_path: '',
          gherkin_path: '',
          section_path: ''
        }
      end

      # check if the configuration fields exist in the file
      def check_capivara_file_fields(file)
        data = config_schema_template
        fields = data.map { |key, _| key.to_s }

        fields_empty = []

        fields.each do |field|
          next if file.key?(field)

          fields_empty << field
        end

        return if fields_empty.empty?

        warn "Settins file is not properly configured, require #{fields_empty} in the capivara.json"
        exit(-1)
      end

      # read a template yaml content
      #
      # file (string): template_yaml_path
      def load_template_file(file)
        @data_schema_template = YAML.load(File.read(file))
      end

      # return a page type
      #
      # schema_type (string): default_back | default_front
      #
      # default_front => '/page_object/pages'
      # default_back => '/services'
      def page_object_type_by_schema(schema_type)
        case schema_type
        when 'default_front'
          '/page_object/pages'
        when 'default_back'
          '/services'
        else
          warn 'Schema not found'
          exit(-1)
        end
      end

      def search_template(templates_path, _schema_type)
        all_arqv ||= []

        if Dir.exist?(templates_path) || !Dir.empty?(templates_path)
          Dir.foreach(templates_path) do |arqv|
            next if ['.', '..'].include?(arqv)

            all_arqv << File.basename(arqv, '*')
          end
          puts 'Templates folder OK'.colorize(:green)
        else
          warn 'The templates folder could not be found or is empty'
          warn "Full path: #{templates_path}".colorize(:yellow)
          exit(-1)
        end
      end
    end
  end
end

# require 'pry-byebug'
#
# class Teste
#  include Commands::Handlers::CommandData
#
#  def initialize
#    @a = data_config
#  end
#
#  def teste
#    @a
#  end
# end
#
# a = Teste.new
# p a.teste
