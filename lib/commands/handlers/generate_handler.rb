module Commands
  module Handlers
    module GenerateHandler
      def handle_check_file(path)
        if File.exist?(path)
          warn 'The file already exists. Do you want to overwrite it? [y]es/[n]o'
          answer = $stdin.gets.chomp.downcase
          if %w[y yes].include?(answer)
            true
          else
            false
          end
        else
          true
        end
      end
    end
  end
end
