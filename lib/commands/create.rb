module Commands
  class Create
    include Commands::Handlers::CommandData

    def initialize(project_name)
      @data = data_create
      @data[:project_name] = File.basename(project_name)
      @data[:project_root_path] = File.join(Dir.pwd, project_name)
    end

    def run_create
      search_template(@data[:templates_path], @data[:schema_type])
      schema = load_template(File.join(@data[:templates_path], "#{@data[:schema_type]}.yml"))
      create_dir(@data[:project_root_path])
      create_template(@data[:project_root_path], schema)
      create_configs
    end

    private

    def create_configs
      pages = if @data[:schema_type] == 'default_front'
                '/page_objects/pages'
              else
                '/services'
              end
      features_path = File.join(@data[:project_root_path], 'features')
      pages_path = File.join(features_path, pages)
      steps_path = File.join(features_path, '/step_definitions')
      gherkin_path = File.join(features_path, '/specs')
      section_path = File.join(features_path, "#{pages}/sections")

      data = {
        project_name: @data[:project_name],
        project_path: @data[:project_root_path],
        project_schema: @data[:schema_type],
        features_path: features_path,
        pages_path: pages_path,
        steps_path: steps_path,
        gherkin_path: gherkin_path,
        section_path: section_path
      }

      create_config_json(data)
    end

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

    def load_template(template_path)
      YAML.load(File.read(template_path))
    end

    def search_template(template_path, schema_type)
      all_arqv ||= []

      if Dir.exist?(template_path) || !Dir.empty?(template_path)
        Dir.foreach(templates_path) do |arqv|
          next if arqv == '.' || arqv == '..'

          all_arqv << File.basename(arqv,'.*')
        end
        STDOUT.puts "Templates folder OK".colorize(:green) if all_arqv.include?(schema_type)
      else
        STDERR.puts "Templates folder not exists or empty".colorize(:red)
        STDERR.puts "Full path: #{template_path}".colorize(:yellow)
        exit -1
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
        STDERR.puts "#{name} #{File.basename(path)} not created".colorize(:red)
        STDERR.puts "Full Path: #{path}".colorize(:yellow)
      end

      result
    end

    def create_file(path, content = nil)
      File.open(path, 'w') do |file|
        if check_existence(path, :file)
          STDOUT.puts "Created: #{File.basename(path)}".colorize(:green) unless File.basename(path) == '.keep'
        end

        unless content.nil?
          file.write(content)
          file.close
        end
      end
    end

    def create_dir(path)
      FileUtils.mkdir_p(path)
      if check_existence(path, :dir)
        STDOUT.puts "Created: #{File.basename(path)}".colorize(:green)
      end
    end
  end
end
