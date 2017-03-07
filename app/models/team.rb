class Team < ApplicationRecord
  serialize :members, Array


  validates :team_name, presence: true, length: {minimum: 3, maximum: 24}, allow_blank: false
  validates :team_img, presence: true, allow_blank: false
  validates :team_link , presence: true, allow_blank: true
  validates :video_link, presence: true, allow_blank: true
  validates :description, presence: true, allow_blank: true
  validates :challenge_id, presence: true, allow_blank: false
  validates :contact_email, presence: true, allow_blank: false
  validates :contact_phone, presence: true, allow_blank: true
  validates :members, presence: true, length: { maximum: 5 }, allow_blank: false
  # TODO: regex validations for each of these fields.

  private

end
