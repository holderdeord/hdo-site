# encoding: utf-8

class PartyUploader < CarrierWave::Uploader::Base
  include Hdo::Utils::Uploader

  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.slug}"
  end

  def default_url
    asset_path "party-logos-stripped/unknown.png"
  end

  version :medium do
    process :scale => [128, 128]
  end

  version :small do
    process :scale => [32, 32]
  end

  def filename
    digest(:logo) if original_filename.present?
  end
end
