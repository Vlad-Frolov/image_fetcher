# frozen_string_literal: true

class ImagesDownloadService
  def initialize(file_path, batch_size)
    @file_path = file_path
    @batch_size = batch_size
    @target_folder = File.join(File.dirname(file_path), 'images')
  end

  def call
    @failed_downloads = []

    File.foreach(file_path).each_slice(batch_size) do |batch_urls|
      failed_downloads.concat(ImageBatchesDownloadService.new(batch_urls.map(&:strip), target_folder).call)
    end

    failed_downloads
  end

  private

  attr_reader :file_path, :batch_size, :target_folder, :failed_downloads
end
