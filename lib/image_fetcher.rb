#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

Dir["#{File.dirname(__FILE__)}/image_fetcher/**/*.rb"].sort.each(&method(:require))

FileUtils.mkdir_p File.join(File.dirname(ARGV[0]), 'images')

result = ::ImageFetcher::Downloader.process_from(ARGV[0], ARGV[1] || 8)
puts result.failed_downloads
