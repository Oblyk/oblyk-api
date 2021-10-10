# frozen_string_literal: true

class GuideBookWeb < ApplicationRecord
  include ActivityFeedable

  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  delegate :latitude, to: :crag
  delegate :longitude, to: :crag

  delegate :feed_parent_id, to: :crag
  delegate :feed_parent_type, to: :crag
  delegate :feed_parent_object, to: :crag

  validates :name, :url, presence: true

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      url: url,
      publication_year: publication_year,
      crag: {
        id: crag.id,
        name: crag.name,
        slug_name: crag.slug_name
      },
      creator: {
        uuid: user&.uuid,
        name: user&.full_name,
        slug_name: user&.slug_name
      },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
