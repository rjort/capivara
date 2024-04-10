module Commands
  module Handlers
    module ValidateArgValue
      # Valida se o valor do comando possui caracteres especiais
      def self.valid_arguments?(value)
        if value.match(/[^\w\s\/]/)
          STDERR.puts 'Please remove any special characters from the command.'.colorize(:yellow)
          exit 1
        end
        if value.length > 31
          STDERR.puts 'Command cannot be longer than 31 characters.'.colorize(:yellow)
          exit 1
        end
      end
    end
  end
end
