# frozen_string_literal: true

require 'byebug'

describe ImageBatchesDownloadService do
  let(:target_folder) { Dir.mktmpdir }
  let(:fixtures_path) { "#{File.dirname(__FILE__)}/fixtures/" }
  let(:images) do
    {
      'airplane.png' => 'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
      'arctichare.png' => 'https://homepages.cae.wisc.edu/~ece533/images/arctichare.png'
    }
  end

  describe '#call' do
    subject { described_class.new(images.values, target_folder).call }

    context 'when there are no errors' do
      before do
        images.each do |image_name, image_url|
          stub_request(:get, image_url).to_return(status: 200, body: File.new("#{fixtures_path}#{image_name}"))
        end
      end

      it 'downloads images into the target folder' do
        expect(subject).to eq([])

        # compares fixture file names with downloaded file names
        downloaded_images = Dir["#{target_folder}/*.png"].map(&File.method(:basename))
        expect(downloaded_images).to match_array(images.keys)

        # compares fixture files contents with downloaded files contents
        downloaded_images.each do |image_path|
          donwloaded_file = "#{target_folder}/#{image_path}"
          fixture_file = "#{fixtures_path}#{File.basename(image_path)}"

          expect(FileUtils.compare_file(donwloaded_file, fixture_file)).to be(true)
        end
      end
    end

    context 'when an exception is occurred' do
      before { images.each_value { |image_url| stub_request(:get, image_url).and_raise(exception_class) } }

      shared_examples "returns errors and doesn't download images " do
        it do
          expect(subject.map(&:keys).flatten).to match_array(images.values.map { |url| URI.parse(url) })
          expect(subject.map(&:values).flatten).to match_array(Array.new(2) { a_kind_of(exception_class) })

          expect(Dir["#{target_folder}/*.png"].map(&File.method(:basename))).to be_empty
        end
      end

      context 'when Timeout Error is occurred' do
        let(:exception_class) { Timeout::Error }

        it_behaves_like "returns errors and doesn't download images "
      end

      context 'when Socket Error is occurred' do
        let(:exception_class) { SocketError }

        it_behaves_like "returns errors and doesn't download images "
      end

      context 'when URI Invalid Error is occurred' do
        let(:exception_class) { URI::InvalidURIError }

        it_behaves_like "returns errors and doesn't download images "
      end
    end
  end
end
