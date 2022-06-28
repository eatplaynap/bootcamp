# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'minitest/mock'
require 'minitest/retry'
require 'supports/api_helper'
require 'supports/vcr_helper'
require 'abstract_notifier/testing/minitest'

Capybara.default_max_wait_time = 5
Capybara.disable_animation = true
Webdrivers.cache_time = 86_400
Minitest::Retry.use! if ENV['CI']
Selenium::WebDriver.logger.ignore(:browser_options) # TODO: Remove it when capybara-3.36.0 greater is released.

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include Sorcery::TestHelpers::Rails::Integration
  include APIHelper
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  ActionDispatch::SystemTesting::Server.silence_puma = true
end

# Rails 7 の ActiveStorage::FixtureSet.blob と同様の機能を実装
# Pull Request #4182 「Update rails 7.0.2.2」の完了後に削除する
# => test/fixtures/active_storage/blobs.yml でActiveStorage::FixtureSet.blob を使うように変更する
module BlobFixtureSet
  def fixture(filename:, **attributes)
    blob = new(
      filename: filename,
      key: generate_unique_secure_token
    )
    io = Rails.root.join("test/fixtures/files/#{filename}").open
    blob.unfurl(io)
    blob.assign_attributes(attributes)
    blob.upload_without_unfurling(io)

    blob.attributes.transform_values { |values| values.is_a?(Hash) ? values.to_json : values }.compact.to_json
  end
end
ActiveStorage::Blob.extend BlobFixtureSet
