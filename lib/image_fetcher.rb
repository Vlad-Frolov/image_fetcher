#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

Dir["#{File.dirname(__FILE__)}/image_fetcher/*.rb"].sort.each(&method(:require))

unless File.file?(ARGV[0].to_s)
  puts "file '#{ARGV[0]}' not found"
  exit
end

FileUtils.mkdir_p File.join(File.dirname(ARGV[0]), 'images')
puts ImagesDownloadService.new(ARGV[0], ARGV[1]&.to_i || 8).call
