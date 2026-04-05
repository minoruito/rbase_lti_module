# frozen_string_literal: true

require_relative "rbase_lti_module/version"
require_relative "rbase_lti_module/engine"
Dir[File.dirname(__FILE__) + '/LTI/**/*.rb'].each {|file| require_relative file }

module RbaseLtiModule
  class Error < StandardError; end
  # Your code goes here...
  class Railtie < Rails::Railtie
    railtie_name :ecr_reference

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/../tasks/*.rake").each { |f| load f }
    end
  end
end
