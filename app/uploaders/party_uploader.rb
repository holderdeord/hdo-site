# encoding: utf-8

class PartyUploader < CarrierWave::Uploader::Base
  include Hdo::Utils::Uploader

  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    asset_path "party-logos-stripped/unknown.png"
  end

  version :extra_large do
    process :resize_to_fit => [500, 500]
  end

  version :large do
    process :resize_to_fit => [250, 250]
  end

  version :medium do
    process :resize_to_fit => [125, 125]
  end

  version :small do
    process :resize_to_fit => [60, 60]
  end

  version :extra_small do
    process :resize_to_fit => [30, 30]
  end

end
