# frozen_string_literal: true

require 'open-uri'
require 'socket'
require 'timeout'

class ImageBatchesDownloadService
  DOWNLOAD_ERRORS = [
    NoMethodError,
    OpenURI::HTTPError,
    SocketError,
    Timeout::Error,
    URI::InvalidURIError
  ].freeze

  def initialize(batch_urls, target_folder)
    @batch_urls = batch_urls
    @target_folder = target_folder
  end

  def call
    @failed_downloads = []

    batch_urls.map { |url| Thread.new { download(url) } }.each(&:join)

    failed_downloads
  end

  private

  def download(url)
    url = URI.parse(url)

    raise URI::InvalidURIError, 'Invalid Url' unless url.respond_to?(:open)

    url.open(redirect: false, open_timeout: 10, read_timeout: 10) do |stream|
      File.open(new_file_name_for(url), 'w') { |f| f.puts stream.read }
    end
  rescue *DOWNLOAD_ERRORS => e
    (@semaphore ||= Mutex.new).synchronize { failed_downloads.push(url => e) }
  end

  def new_file_name_for(url)
    "#{target_folder}/#{File.basename(URI(url).path)}"
  end

  attr_reader :batch_urls, :target_folder, :failed_downloads
end
