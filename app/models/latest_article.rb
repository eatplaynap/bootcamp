# frozen_string_literal: true

class ExternalEntry < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  THUMBNAIL_SIZE = '88x88>'
  has_one_attached :thumbnail
  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true
  validates :published_at, presence: true

  def thumbnail_url
    if thumbnail.attached?
      thumbnail.variant(resize: THUMBNAIL_SIZE).processed.url
    else
      image_url('/images/external_entries/thumbnails/blank.svg')
    end
  end
end
