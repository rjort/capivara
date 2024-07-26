module Commands
  module Handlers
    module CreateHandler
      def self.project_folder_exists?(path)
        result = Dir.exist?(path)
        if result
          warn 'Theres already a project with this name. Would you like to replace it? [y]es/[n]o'.colorize(:yellow)
          answer = $stdin.gets.chomp.downcase
          return true if %w[y yes].include?(answer)

          warn 'Project not created'
          false
        else
          true
        end
      end
    end
  end
end
