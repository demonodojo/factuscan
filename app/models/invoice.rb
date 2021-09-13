class Invoice < ApplicationRecord
  has_one_attached :image

  def image_url
    if image.attached?
      image.blob.service_url
    end
  end
end
