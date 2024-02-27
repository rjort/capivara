module Commands
  class Create
    include Commands::Handle::CommandData

    def initialize(project_name)
      @data = data_create
      @data[:project_name] = File.basename(project_name)
      @data[:project_root_path] = File.join(Dir.pwd, project_name)
    end

    def run_create
      search_template(@data[:templates_path], @data[:schema_type])
      schema = load_template(File.join(@data[:templates_path], "#{@data[:schema_type]}.json"))
      create_dir(@data[:project_root_path])
      create_template(@data[:project_root_path], schema)
    end

    private

    def create_template(project_root_path, template)
      template.each do |name, content|
        name = @data[:project_name] if name =~ /project/
        path = File.join(project_root_path, name.to_s)
        if content.is_a?(Hash)
          create_dir(path)
          create_template(path, content)
        elsif content.nil?
          create_file(path)
        else
          create_file(path, content)
        end
      end
    end

    # return JSON object
    def load_template(template_path)
      json_data = File.read(template_path)

      JSON.parse(json_data)
    end

    # Search 
    def search_template(template_path, schema_type)
      all_arqv ||= []

      if Dir.exist?(template_path) || !Dir.empty?(template_path)
        Dir.foreach(templates_path) do |arqv|
          next if arqv == '.' || arqv == '..'

          all_arqv << File.basename(arqv,'.*')
        end
        puts "Templates folder OK".colorize(:green) if all_arqv.include?(schema_type)
      else
        STDERR.puts "Templates folder not exists or empty".colorize(:red)
        STDERR.puts "Full path: #{template_path}".colorize(:yellow)
        exit -1
      end
    end

    def check_file(path)
      if File.file?(path)
        puts "Created: #{File.basename(path)}".colorize(:green) unless File.basename(path) == '.keep'
      else
        STDERR.puts "File #{File.basename(path)} not created".colorize(:red)
        STDERR.puts "Full path: #{path}".colorize(:yellow)
        exit -1
      end
    end
    
    def check_dir(path)
      if File.directory?(path)
        puts "Created: #{File.basename(path)}".colorize(:green)
      else
        STDERR.puts "Directory #{File.basename(path)} not created".colorize(:red)
        STDERR.puts "Full path: #{path}".colorize(:yellow)
        exit -1
      end
    end

    def create_file(path, content = nil)
      File.open(path, 'w') do |file|
        check_file(file)
        unless content.nil?
          file.write(content)
          file.close
        end
      end
    end

    def create_dir(path)
      FileUtils.mkdir_p(path)
      check_dir(path)
    end
  end
end
