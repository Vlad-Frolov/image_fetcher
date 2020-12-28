# frozen_string_literal: true

module ImageFetcher
  class Downloader
    def self.process_from(file_path, batch_size = 8)
      new(file_path, batch_size).process
    end

    def initialize(file_path, batch_size)
      @urls_file_path = file_path
      @batch_size = batch_size
      @target_folder = File.join(File.dirname(urls_file_path), 'images')
    end

    def process
      @failed_downloads = []

      File.foreach(urls_file_path).each_slice(batch_size) do |batch|
        failed_downloads.concat((ImageFetcher::Threads::Downloading.run_for(batch.map(&:strip), target_folder)))
      end

      failed_downloads
    end

    private

    attr_reader :urls_file_path, :batch_size, :target_folder, :failed_downloads
  end
end
