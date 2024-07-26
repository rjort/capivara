module Commands
  class Create
    include Commands::Handlers::CommandData

    def initialize(project_name)
      process_data_create
      @data = configs
      @data[:project_name] = File.basename(project_name).capitalize
      @data[:project_root_path] = project_name
      @template_content = data_schema_template
    end

    def run_create
      create_dir(@data[:project_root_path])
      create_configs
      create_template(@data[:project_root_path], @template_content)
    end

    private

    def create_configs
      @data[:features_path] = 'features'
      @data[:json_path]     = 'capivara.json'
      @data[:pages_path]    = File.join(@data[:features_path], page_type)
      @data[:steps_path]    = File.join(@data[:features_path], '/step_definitions')
      @data[:gherkin_path]  = File.join(@data[:features_path], '/specs')
      @data[:section_path]  = File.join(@data[:features_path], "#{page_type}/sections")
    end

    def create_template(project_root_path, template)
      template.each do |name, content|
        name = @data[:project_name].downcase if name =~ /project/
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

    def check_existence(path, type)
      if type == :file
        result = File.file?(path)
        name = 'File'
      elsif type == :dir
        result = File.directory?(path)
        name = 'Directory'
      else
        raise ArgumentError, "Invalid type: #{type}. Expected :file or :dir"
      end

      unless result
        warn "#{name} #{File.basename(path)} not created".colorize(:red)
        warn "Full Path: #{path}".colorize(:yellow)
      end

      result
    end

    def create_file(path, content = nil)
      File.open(path, 'w') do |file|
        if check_existence(path, :file) && (File.basename(path) != '.keep')
          puts "Created: #{File.basename(path)}".colorize(:green)
        end

        unless content.nil?
          file.write(content)
          file.close
        end
      end
    end

    def create_dir(path)
      FileUtils.mkdir_p(path)
      return unless check_existence(path, :dir)

      puts "Created: #{File.basename(path)}".colorize(:green)
    end
  end
end
