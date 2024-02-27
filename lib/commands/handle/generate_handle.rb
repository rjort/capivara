module Commands
  module Handle
    module GenerateHandle
      def handle_write(path, text)
        if File.exist?(path)
          true
        elsif !File.exist?(path)
          arqv = File.open path, 'w'
          arqv.puts text
          arqv.close
          false
        else
          nil
        end
      end

      def handle_create(full_path, text)
        key = yield(full_path, text) if block_given?
  
        if key
          puts "The file already exists. Do you want to overwrite it?( [y]es/[n]o".colorize(:yellow)
          answer = $stdin.gets.chomp.downcase
          if answer == 'y' || answer == 'yes'
            arqv = File.open full_path, 'w'
            arqv.puts text
            arqv.close
            puts "Overwritten: #{File.basename(full_path)}".colorize(:green)
          else
            exit 1
          end
        elsif !key
          puts "Created: #{File.basename(full_path)}".colorize(:green)
        else
          STDERR.puts "File #{File.basename(full_path)} not created".colorize(:red)
          STDERR.puts "Full path: #{full_path}".colorize(:yellow)
          exit 1
        end
      end
    end
  end
end