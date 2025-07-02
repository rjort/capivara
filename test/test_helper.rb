require "minitest/autorun"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

begin
  require 'colorize'
rescue LoadError
  module Colorize; end
  class String
    def colorize(*); self; end
  end
  $LOADED_FEATURES << 'colorize.rb'
end

%w[pry pry-byebug].each do |lib|
  begin
    require lib
  rescue LoadError
    module Kernel; end
    $LOADED_FEATURES << "#{lib}.rb"
  end
end

# Add test libraries you want to use here, e.g. mocha
# Add helper classes or methods here, too
