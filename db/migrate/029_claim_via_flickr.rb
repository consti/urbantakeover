class ClaimViaFlickr < ActiveRecord::Migration
  def self.up
    add_column :claims, :flickr_photo_id, :string
    add_column :claims, :proof_image_url, :string
  end

  def self.down
    remove_column :claims, :flickr_photo_id
    remove_column :claims, :proof_image_url
  end
end
