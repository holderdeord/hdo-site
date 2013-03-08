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

  # TODO: quality, strip, sharpen, scale https://github.com/fxposter/carrierwave-processing

  version :extra_large do
    process resize_to_fit: [480, 640]
  end

  version :large do
    process resize_to_fit: [240, 320]
  end

  version :medium do
    process resize_to_fit: [120, 160]
  end

  version :small do
    process resize_to_fit: [60, 80]
  end

  version :extra_small do
    process resize_to_fit: [30, 40]
  end

  def filename
    digest(:image) if original_filename.present?
  end

end
