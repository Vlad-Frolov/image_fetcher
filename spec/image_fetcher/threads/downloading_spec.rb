# frozen_string_literal: true

describe ImageFetcher::Threads::Downloading do
  let(:target_folder) { Dir.mktmpdir }
  let(:images) do
    {
      'airplane.png' => 'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
      'arctichare.png' => 'https://homepages.cae.wisc.edu/~ece533/images/arctichare.png'
    }
  end

  describe '::run_for' do
    subject(:result) { described_class.run_for(images.values, target_folder) }

    before do
      stub = double(described_class)
      expect(described_class).to receive(:new).with(images.values, target_folder).and_return(stub)
      expect(stub).to receive(:run).and_return('passed')
    end

    it('works') { should be('passed') }
  end

  describe '#run' do
    subject(:result) { described_class.new(images.values, target_folder).run }

    before do
      images.each do |image_name, url|
        stub_request(:get, url).with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.new("#{File.dirname(__FILE__)}/images/#{image_name}"), headers: {})
      end
    end

    it 'downloads images into target folder' do
      expect(result).to eq([])

      downloaded_images = Dir["#{target_folder}/*.png"].map(&File.method(:basename))
      expect(downloaded_images).to match_array(images.keys)

      downloaded_images.each do |path|
        result_file = "#{target_folder}/#{path}"
        expected_file = "#{File.dirname(__FILE__)}/images/#{File.basename(path)}"

        expect(FileUtils.compare_file(result_file, expected_file)).to be(true)
      end
    end
  end
end
