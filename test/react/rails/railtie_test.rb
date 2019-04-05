require 'test_helper'

class RailtieTest < ActionDispatch::IntegrationTest
  test 'reloaders are configured after initializers are loaded' do
    @test_file = File.expand_path("../../#{DUMMY_LOCATION}/app/pants/yfronts.js", File.dirname(__FILE__))
    FileUtils.touch @test_file
    results = Dummy::Application.reloaders.map(&:updated?)
    assert_includes(results, true)
  end

  test "doesn't register a new reloader when no folders exist" do
    with_empty_server_renderer_directories do
      assert_no_difference -> { Rails.application.config.to_prepare_blocks.count } do
        assert_no_difference -> { Rails.application.reloaders.count } do
          run_initializer("react_rails.add_watchable_files")
        end
      end
    end
  end

  private

  def run_initializer(initializer_name)
    initializer = Rails.application.initializers.find do |initializer|
      initializer.name == initializer_name
    end
    initializer.run(Rails.application)
  end

  def with_empty_server_renderer_directories
    old_dirs = Rails.application.config.react.server_renderer_directories
    Rails.application.config.react.server_renderer_directories = %w(invalid_dir)
    yield
  ensure
    Rails.application.config.react.server_renderer_directories = old_dirs
  end
end
