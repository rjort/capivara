module Commands
  # Class: Commands::Generate
  #
  # Description:
  # The Generate class generates files based on the provited args.
  # It is useful for quickly creating files with predefinited content.
  class Generate
    include Commands::Handlers::CommandData
    include Commands::Handlers::GenerateHandler

    attr_reader :args

    def initialize
      process_validade_config_file('capivara.json')
      @args = data_args_generate
      @json_settings = read_capivara_file
    end

    # Create a file
    #
    # path (string): File.join(config['type_path'], flag_arg)
    # config_path (string): capivara.json type path
    def run_generate(path, config_path)
      if config_path.empty?
        warn 'Config path empty. Check your config file'.colorize(:yellow)
        exit(-1)
      end

      project_name = @json_settings['project_name']
      base_name = File.basename(path)
      full_path = File.join(path, base_name)

      FileUtils.mkdir_p(path)

      case args[:flag]
      when 'G', 'gherkin'
        File.open("#{full_path}.feature", 'w') { |file| file.puts text_base_gherkin }
        puts "Created: #{File.basename(path)}.feature".colorize(:green)
      when 'p', 'page'
        File.open("#{full_path}.rb", 'w') { |file| file.puts text_base_page(project_name, base_name) }
        puts "Created: #{File.basename(path)}.rb".colorize(:green)
      when 's', 'step'
        File.open("#{full_path}_step.rb", 'w') { |file| file.puts text_base_step }
        puts "Created: #{File.basename(path)}_step.rb".colorize(:green)
      when 'S', 'section'
        File.open("#{full_path}.rb", 'w') { |file| file.puts text_base_section(project_name, base_name) }
        puts "Created: #{File.basename(path)}.rb".colorize(:green)
      end
    end

    def run_all
      path = ''
      key = nil
      { 'G' => @json_settings['gherkin_path'], 'p' => @json_settings['pages_path'],
        's' => @json_settings['steps_path'] }.each do |flag, type_path|
        file = File.join(type_path, args[:arg])
        if flag == 'G'
          path = File.join(file, "#{File.basename(file)}.feature")
          key = check_if_file_exist(path)
        end
        if flag == 'p'
          path = File.join(file, "#{File.basename(file)}.rb")
          key = check_if_file_exist(path)
        end
        if flag == 's'
          path = File.join(file, "#{File.basename(file)}_step.rb")
          key = check_if_file_exist(path)
        end

        @args[:flag] = flag
        run_generate(file, type_path) if key
      end
    end

    def check_if_file_exist(path)
      handle_check_file(path)
    end

    private

    def convert_to_camel_case(text)
      text.split('_').map(&:capitalize).join
    end

    def text_base_section(project_name, file_name)
      <<~SECTION
        module #{convert_to_camel_case(project_name)}
          module Section
            module #{convert_to_camel_case(file_name)}
              class Home < SitePrism::Section
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
              class Home < SitePrism::Page
                set_url '/'
              end
            end
          end
        end
      PAGE
    end

    def text_base_gherkin
      <<~GH
        # language: pt
      GH
    end

    def text_base_step
      <<~STEP
        # Dado
        # Quando
        # Então
      STEP
    end
  end
end
