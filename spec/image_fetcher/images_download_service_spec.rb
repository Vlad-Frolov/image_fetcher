# frozen_string_literal: true

require 'spec_helper'

describe ImagesDownloadService do
  let(:image_urls) do
    %w[https://homepages.cae.wisc.edu/~ece533/images/airplane.png
       https://homepages.cae.wisc.edu/~ece533/images/arctichare.png]
  end

  let(:file_path) do
    tempfile = Tempfile.new('urls')
    image_urls.each(&tempfile.method(:puts))
    tempfile.tap(&:flush).path
  end

  describe '#call' do
    subject { described_class.new(file_path, 3).call }

    let(:batches_download_service) { double('Batches Download Service') }

    before do
      allow(ImageBatchesDownloadService)
        .to receive(:new).with(image_urls, File.join(File.dirname(file_path), 'images'))
                         .and_return(batches_download_service)
      allow(batches_download_service).to receive(:call).and_return(expected_result)
    end

    shared_examples 'returns an expected result and calls Images Batches Download Service' do
      it do
        expect(subject).to eq(expected_result)
        expect(batches_download_service).to have_received(:call).with(no_args)
      end
    end

    context 'when Images Batches Download Service returns no errors' do
      let(:expected_result) { [] }

      it_behaves_like 'returns an expected result and calls Images Batches Download Service'
    end

    context 'when Images Batches Download Service some errors' do
      let(:expected_result) { ['Here is an error #1', 'Here is an error #2'] }

      it_behaves_like 'returns an expected result and calls Images Batches Download Service'
    end
  end
end
