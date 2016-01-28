#
# Author:: Partner Engineering <partnereng@chef.io>
# Copyright (c) 2016, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '../libraries/gce_helpers'

class GceHelpersTester
  include MarketplaceImageCookbook::GceHelpers
end

describe MarketplaceImageCookbook::GceHelpers do
  let(:tester) { GceHelpersTester.new }

  describe '#gce_metadata_source' do
    it 'returns the correct file based on the role' do
      expect(tester.gce_metadata_source('aio')).to eq('gce_image_metadata_aio.json.erb')
      expect(tester.gce_metadata_source('server')).to eq('gce_image_metadata_aio.json.erb')
      expect(tester.gce_metadata_source('compliance')).to eq('gce_image_metadata_compliance.json.erb')
    end
  end

  describe '#gce_product_name' do
    it 'returns the correct product names' do
      expect(tester.gce_product_name('aio')).to eq('Chef Server')
      expect(tester.gce_product_name('server')).to eq('Chef Server')
      expect(tester.gce_product_name('compliance')).to eq('Chef Compliance')
    end

    it 'raises an exception if an unknown role is supplied' do
      expect { tester.gce_product_name('non-existent') }.to raise_error(RuntimeError)
    end
  end

  describe '#gce_listing_name' do
    it 'returns a properly-formatted listing name' do
      expect(tester).to receive(:gce_product_name).with('aio').and_return('Chef Product')
      expect(tester).to receive(:license_count_text).with('aio', 100).and_return(100)
      expect(tester.gce_listing_name('aio', 100)).to eq('Chef Product (100 node license)')
    end
  end

  describe '#gce_listing_description' do
    it 'returns the proper listing descriptions' do
      expect(tester.gce_listing_description('aio', 5)).to include('The Chef Server image helps you')
      expect(tester.gce_listing_description('aio', 5)).to include('is free of software charge')
      expect(tester.gce_listing_description('aio', 10)).not_to include('is free of software charge')
      expect(tester.gce_listing_description('aio', 10)).to include('is licensed for 10 nodes')

      expect(tester.gce_listing_description('server', 5)).to include('The Chef Server image helps you')
      expect(tester.gce_listing_description('server', 5)).to include('is free of software charge')
      expect(tester.gce_listing_description('server', 10)).not_to include('is free of software charge')
      expect(tester.gce_listing_description('server', 10)).to include('is licensed for 10 nodes')

      expect(tester.gce_listing_description('compliance', 10)).to include('The Chef Compliance server')
    end
  end

  describe '#license_count_text' do
    it 'returns the proper license count text' do
      expect(tester.license_count_text('aio', 5)).to eq('Free 5')
      expect(tester.license_count_text('aio', 10)).to eq(10)
      expect(tester.license_count_text('server', 5)).to eq('Free 5')
      expect(tester.license_count_text('server', 10)).to eq(10)
      expect(tester.license_count_text('compliance', 5)).to eq(5)
      expect(tester.license_count_text('compliance', 10)).to eq(10)
    end
  end
end
