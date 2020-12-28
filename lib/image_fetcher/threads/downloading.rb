# frozen_string_literal: true

require 'open-uri'

module ImageFetcher
  module Threads
    class Downloading
      def self.run_for(batch, target_folder)
        new(batch, target_folder).run
      end

      def initialize(batch, target_folder)
        @batch = batch
        @target_folder = target_folder
      end

      def run
        @failers = []
        @threads = batch.each_with_object([]) do |url, threads|
          threads << Thread.new do
            URI.parse(url).open { |stream| File.open(new_file_name_for(url), 'w') { |f| f.puts stream.read } }
          rescue OpenURI::HTTPError => e
            @failers.push(url => e)
          end
        end

        threads.each(&:join)

        failers
      end

      private

      def new_file_name_for(url)
        "#{target_folder}/#{File.basename(URI(url).path)}"
      end

      attr_reader :batch, :target_folder, :threads, :failers
    end
  end
end
