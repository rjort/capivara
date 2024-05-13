module Commands
  class Config
    include Commands::Handlers::CommandData

    def initialize
      @data ||= data_config
    end

    def run_config
      if File.directory?(@data[:features_path])
        create_capivara_json(@data[:json_path])
        define_json_data
      else
        puts "Features project folder not exists".colorize(:yellow)
      end
    end

    private

    def define_json_data
      data = {
        project_name: @data[:project_name],
        project_path: @data[:project_root_path],
        project_schema: 'custom',
        features_path: @data[:features_path],
        pages_path: '',
        steps_path: '',
        gherkin_path: '',
        section_path: ''
      }

      create_config_json(data)
    end

    # TODO: remover logica de criacao/substituicao
    def create_capivara_json(json_path)
      if !File.exist?(json_path)
        File.open(json_path, 'w') {}
        STDOUT.puts "Created: #{File.basename(json_path)}".colorize(:green)
        STDOUT.puts "Configuration file created, please adjust the paths for your project's model.".colorize(:green)
      elsif File.exist?(json_path)
        STDERR.puts "The file already exists. Do you want to overwrite it?( [y]es/[n]o"
        answer = $stdin.gets.chomp.downcase
        if answer == 'y' || answer == 'yes'
          File.open(json_path, 'w') {}
          STDOUT.puts "Overwritten: #{File.basename(json_path)}".colorize(:green)
        else
          STDERR.puts "Config file #{File.basename(json_path)} not created".colorize(:yellow)
          exit -1
        end
      else
        exit -1
      end
    end
  end
end