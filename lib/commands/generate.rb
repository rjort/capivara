module Commands
  class Generate
    include Commands::Handle::CommandData
    include Commands::Handle::GenerateHandle

    def initialize
      @data ||= data_generate
      @data[:project_name] = File.basename(Dir.pwd)
    end

    def run_generate
      case @data[:generate_flag]
      when 'G'
        generate(@data[:generate_flag], @data[:generate_arg], @data[:gherkin_path])
      when 'p'
        generate(@data[:generate_flag], @data[:generate_arg], @data[:pages_path])
      when 's'
        generate(@data[:generate_flag], @data[:generate_arg], @data[:steps_path])
      when 'S'
        generate(@data[:generate_flag], @data[:generate_arg], @data[:section_path])
      when 'a'
        run_all(@data)
      else
        exit 1
      end
    end

    private

    def run_all(data)
      {'G'=>data[:gherkin_path], 'p'=>data[:pages_path], 's'=>data[:steps_path]}.each do |arg, type_path|
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
        handle_create(full_path, text_base_page(@data[:project_name], file_name)) do |path, text|
          handle_write(path, text)
        end
      when 's'
        full_path = File.join(base_path, "#{file_name}_step.rb")
        handle_create(full_path, text_base_step) do |path, text|
          handle_write(path, text)
        end
      when 'S'
        full_path = File.join(base_path, "#{file_name}.rb")
        handle_create(full_path, text_base_section(@data[:project_name], file_name)) do |path, text|
          handle_write(path, text)
        end
      else
        exit 1
      end
    end

    # Generate a files and dir
    # 
    # 
    # 
    # $ capivara g -G data/kpi
    # => Creates: ./features/specs/data/kpi/kpi.feature
    # 
    # file_name = kpi
    # base_file_path = data/kpi
    # base_path = ./features/specs/data/kpi
    # full_path = ./features/specs/data/kpi/kpi.feature
    def generate(arg, base_file_path, type_path)
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
