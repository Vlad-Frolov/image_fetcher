# frozen_string_literal: true

require 'open-uri'
require 'socket'
require 'timeout'

module ImageFetcher
  module Threads
    class Downloading
      ERRORS = [
        OpenURI::HTTPError,
        Timeout::Error,
        URI::InvalidURIError,
        SocketError,
        NoMethodError
      ].freeze

      def self.run_for(batch, target_folder)
        new(batch, target_folder).run
      end

      def initialize(batch, target_folder)
        @batch = batch
        @target_folder = target_folder
      end

      def run
        @failers = []
        batch.map { |url| Thread.new { download(url) } }.each(&:join)
        failers
      end

      private

      def download(url)
        url = URI.parse(url)

        raise URI::InvalidURIError, 'Invalid Url' unless url.respond_to?(:open)

        url.open(redirect: false, open_timeout: 10, read_timeout: 10) do |stream|
          File.open(new_file_name_for(url), 'w') { |f| f.puts stream.read }
        end
      rescue *ERRORS => e
        (@semaphore ||= Mutex.new).synchronize { failers.push(url => e) }
      end

      def new_file_name_for(url)
        "#{target_folder}/#{File.basename(URI(url).path)}"
      end

      attr_reader :batch, :target_folder, :failers
    end
  end
end
