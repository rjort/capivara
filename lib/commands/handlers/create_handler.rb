module Commands
  module Handlers
    module CreateHandler
      def self.project_folder_exists?(path)
        result = Dir.exist?(path)

        if result
          STDERR.puts 'Theres already a project with this name. Would you like to replace it? [y]es/[n]o'.colorize(:yellow)
          answer = $stdin.gets.chomp.downcase
          if answer == 'y' || answer == 'yes'
            return true
          else
            return false
          end
        end
      end
    end
  end
end