# frozen_string_literal: true

describe ImageFetcher::Downloader do
  let(:images) do
    {
      'airplane.png' => 'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
      'arctichare.png' => 'https://homepages.cae.wisc.edu/~ece533/images/arctichare.png'
    }
  end

  let(:file_path) do
    tempfile = Tempfile.new('urls')
    images.values.each(&tempfile.method(:puts))
    tempfile.tap(&:flush).path
  end

  describe '::process_from' do
    subject(:result) { described_class.process_from(file_path, batch_size) }

    let(:batch_size) { (1..8).to_a.sample }

    before do
      stub = double(described_class)
      expect(described_class).to receive(:new).with(file_path, batch_size).and_return(stub)
      expect(stub).to receive(:process).and_return('passed')
    end

    it('works') { should be('passed') }
  end

  describe '#process' do
    subject(:result) { described_class.new(file_path, 4).process }

    before do
      images.each do |image_name, url|
        stub_request(:get, url).with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        ).to_return(status: 200, body: File.new("#{File.dirname(__FILE__)}/threads/images/#{image_name}"), headers: {})
      end
    end

    it 'calls ImageFetcher Threads Donwloading expected times' do
      expect(ImageFetcher::Threads::Downloading).to receive(:run_for)
        .with(images.values, File.join(File.dirname(file_path), 'images')).and_return([])

      expect(result).to eq([])
    end
  end
end
