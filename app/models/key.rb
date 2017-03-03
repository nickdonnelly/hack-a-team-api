class Key < ApplicationRecord

  validates :key, presence: true
  validates :key, uniqueness: true
  validates :privilege_level, presence: true
  validates :privilege_level, numericality: { only_integer: true, in: 0..1 } # 0 or 1
end
