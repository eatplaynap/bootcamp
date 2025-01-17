# frozen_string_literal: true

require 'test_helper'

class GithubGrassTest < ActiveSupport::TestCase
  test '#fetch' do
    skip 'skip until you can keep up with github spec changes'

    VCR.use_cassette 'github_grass/fetch' do
      assert_match(/svg/, GithubGrass.new('komagata').fetch)
      assert_no_match(/svg/, GithubGrass.new('komagata1234').fetch)
    end
  end
end
