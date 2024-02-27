module Commands
  class Config
    include Commands::Handle::CommandData

    def initialize
      @data ||= data_config
      @data[:json_data] ||= define_json_data
    end

    def run_config
      if File.directory?("#{@data[:project_path]}/features")
        create_capivara_json(@data[:json_path])
      else
        puts "Features project folder not exists".colorize(:yellow)
      end
    end

    private

    def define_json_data
      {
        name: @data[:project_name].downcase,
        path: "#{@data[:project_path]}/features/",
      }
    end

    def create_capivara_json(json_path)
      if !File.exist?(json_path)
        File.open(json_path, 'w') { |file| file.write(JSON.pretty_generate(@data[:json_data]))}
        puts "Created: #{File.basename(json_path)}".colorize(:green)
      elsif File.exist?(json_path)
        puts "The file already exists. Do you want to overwrite it?( [y]es/[n]o".colorize(:yellow)
        answer = $stdin.gets.chomp.downcase
        if answer == 'y' || answer == 'yes'
          json = File.open(json_path, 'w') { |file| file.write(JSON.pretty_generate(@data[:json_data])) }
          puts "Overwritten: #{File.basename(json_path)}".colorize(:green)
        else
          exit -64
        end
      else
        STDERR.puts "Config file #{File.basename(json_path)} not created".colorize(:red)
        exit -1
      end
    end
  end
end