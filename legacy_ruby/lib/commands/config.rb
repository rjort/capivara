module Commands
  # Class: Commands::Config
  #
  # Description:
  # The config class initialize a new configuration, creating a json file named 'capivara.json'.
  # The file contains some pre-set configurations and allows for the manual addition of custom settings.
  #
  # Arguments:
  # - $ capivara config --init
  #
  # Methods:
  # run_config: create a new config file
  class Config
    include Handlers::CommandData

    def run_config(path)
      process_data_config
      create_capivara_json(path)
    end

    private

    def create_capivara_json(json_path)
      File.open(json_path, 'w') {}
      puts "Created: #{File.basename(json_path)}".colorize(:green)
      puts "Configuration file created, please adjust the paths for your project's model.".colorize(:green)
    end
  end
end
