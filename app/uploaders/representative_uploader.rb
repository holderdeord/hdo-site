# encoding: utf-8

class RepresentativeUploader < CarrierWave::Uploader::Base
  include Hdo::Utils::Uploader

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.slug}"
  end

  def default_url
    asset_path "representatives/unknown.jpg"
  end

  process :strip
  process sigmoidal_contrast: [3, 20]
  process sharpen: [0, 1.05]
  process quality: 85

  version :large do
    process scale: [480, 640]
  end

  version :medium do
    process scale: [240, 320]
  end

  version :small do
    process scale: [120, 160]
  end

  version :avatar do
    process scale: [256, 384]
    process crop: [256, 256, 0, 0]
  end

  def filename
    digest(:image) if original_filename.present?
  end

end
