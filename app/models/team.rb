class Team < ApplicationRecord
  serialize :members, Array


  validates :team_name, presence: true
  validates :team_img, presence: true
  validates :team_link , presence: true
  validates :video_link, presence: true
  validates :description, presence: true
  validates :challenge_id, presence: true
  validates :contact_email, presence: true
  validates :contact_phone, presence: true
  validates :members, presence: true, length: { maximum: 5 }
  # TODO: regex validations for each of these fields.

  private

end
