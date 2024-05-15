module Commands
  class Generate
    include Commands::Handlers::CommandData
    include Commands::Handlers::GenerateHandler

    def initialize
      @data ||= data_generate
      config_name = get_config_file_name

      # check if config_name (capivara.json) exists
      if File.exist?(config_name) && !File.zero?(config_name)
        content_json = File.read(config_name)

        # check if capivara.json content is empty
        unless content_json.empty?
          @config_file = JSON.parse(File.read(config_name))

          fields = fields_necessary_config_json

          meta_data_fields = check_fields(fields, @config_file)

          unless meta_data_fields[0]
            STDERR.puts "Settings file is not properly configured.: #{meta_data_fields[1]}".colorize(:red)
            exit -1
          end
        else
          STDERR.puts "Settings file is empty.".colorize(:red)
          exit -1
        end
      else
        STDERR.puts "You need to configure your settings file with the file PATHS."
        exit -1
      end
    end

    def run_generate
      case @data[:generate_flag]
      when 'G'
        generate(@data[:generate_flag], @data[:generate_arg], @config_file['gherkin_path'])
      when 'p'
        generate(@data[:generate_flag], @data[:generate_arg], @config_file['pages_path'])
      when 's'
        generate(@data[:generate_flag], @data[:generate_arg], @config_file['steps_path'])
      when 'S'
        generate(@data[:generate_flag], @data[:generate_arg], @config_file['section_path'])
      when 'a'
        run_all(@data, @config_file)
      else
        exit 1
      end
    end

    private

    def check_fields(fields, parsed_file)
      field_empty = true
      parsed_key = ''
      fields.each do |field|
        unless parsed_file.key?(field)
          field_empty = false
          parsed_key = field
          break
        end
      end
      [field_empty, parsed_key]
    end

    def fields_necessary_config_json
      %w(project_name project_path project_schema features_path pages_path steps_path gherkin_path section_path)
    end

    def run_all(data, config_file)
      {'G'=>config_file['gherkin_path'], 'p'=>config_file['pages_path'], 's'=>config_file['steps_path']}.each do |arg, type_path|
        generate(arg, data[:generate_arg], type_path)
      end
    end

    def create_file(arg, file_name, base_path)
      case arg
      when 'G'
        full_path = File.join(base_path, "#{file_name}.feature")
        handle_create(full_path, text_base_gherkin) do |path, text|
          handle_write(path, text)
        end
      when 'p'
        full_path = File.join(base_path, "#{file_name}.rb")
        handle_create(full_path, text_base_page(@config_file['project_name'], file_name)) do |path, text|
          handle_write(path, text)
        end
      when 's'
        full_path = File.join(base_path, "#{file_name}_step.rb")
        handle_create(full_path, text_base_step) do |path, text|
          handle_write(path, text)
        end
      when 'S'
        full_path = File.join(base_path, "#{file_name}.rb")
        handle_create(full_path, text_base_section(@config_file['project_name'], file_name)) do |path, text|
          handle_write(path, text)
        end
      else
        exit 1
      end
    end

    # Generate a files and dir
    # 
    # $ capivara g -G data/kpi
    # => Creates: ./features/specs/data/kpi/kpi.feature
    # 
    # type_path = ./features/specs
    # file_name = kpi
    # base_file_path = data/kpi
    # base_path = ./features/specs/data/kpi
    # full_path = ./features/specs/data/kpi/kpi.feature
    def generate(arg, base_file_path, type_path)
      if type_path.empty?
        STDERR.puts "Config path empty. Check your config file".colorize(:yellow)
        exit -1
      end

      file_name = File.basename(base_file_path)
      base_path = File.join(type_path, base_file_path)

      FileUtils.mkdir_p(base_path)
      create_file(arg, file_name, base_path)
    end

    def convert_to_camel_case(text)
      text.split('_').map(&:capitalize).join
    end

    def text_base_section(project_name, file_name)
      <<~SECTION
      module #{convert_to_camel_case(project_name)}
        module Section
          module #{convert_to_camel_case(file_name)}
            class Home << SitePrism::Section
            end
          end
        end
      end
      SECTION
    end

    # TODO: adicionar recursao para adicionar quantidade de modulos dinamicamente
    # por exemplo: $capivara g nome/do/caminho/completo
    # module #{convert_to_camel_case(project_name)}
    #   module Pages
    #     module Nome
    #       module Do
    #         module Caminho
    #           module Completo
    def text_base_page(project_name, file_name)
      <<~PAGE
      module #{convert_to_camel_case(project_name)}
        module Pages
          module #{convert_to_camel_case(file_name)}
            class Home << SitePrism::Page
              set_url '/'
            end
          end
        end
      end
      PAGE
    end

    def text_base_gherkin
      <<~GH
      #language: pt
      GH
    end

    def text_base_step
      <<~STEP
      Dado('') do; end
      Quando('') do; end
      Então('') do; end
      STEP
    end
  end
end
