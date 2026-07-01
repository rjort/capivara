require_relative 'test_helper'
require 'capivara'

class CreatePathsTest < Minitest::Test
  def setup
    Commands::Handlers::CommandData.template_type('default_front')
    @create = Commands::Create.new('sample_project')
    @create.send(:create_configs)
    @data = @create.instance_variable_get(:@data)
  end

  def test_pages_path_relative
    assert_equal File.join('features', 'page_objects/pages'), @data[:pages_path]
  end

  def test_steps_path_relative
    assert_equal File.join('features', 'step_definitions'), @data[:steps_path]
  end

  def test_gherkin_path_relative
    assert_equal File.join('features', 'specs'), @data[:gherkin_path]
  end

  def test_section_path_relative
    assert_equal File.join('features', 'page_objects/pages', 'sections'), @data[:section_path]
  end
end
