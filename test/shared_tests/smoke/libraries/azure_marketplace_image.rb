require "azure"
require "base64"

module Inspec::Resources
  class AzureMarketplaceImage < Inspec.resource(1)
    name "azure_marketplace_image"
    desc "Resource for inspecting blobs in Azure Storage Service for Chef Marketplace"
    example <<-EOH
describe azure_storage_blob("name_of_my_blob") do
  it { should exist }
end
EOH

    attr_reader :blob_name

    def initialize(blob_name)
      @blob_name = blob_name

      init_azure_settings
    end

    def to_s
      "Azure Blob #{blob_name}"
    end

    def exists?
      Azure.blobs.get_blob_metadata("images", blob_name)
    rescue => e
      puts "WARN: Unable to fetch metadata for blob #{blob_name}: #{e.class} -- #{e.message}"
      false
    else
      true
    end

    private

    def init_azure_settings
      Azure.management_certificate = management_certificate
      Azure.subscription_id        = subscription_id
      Azure.storage_access_key     = storage_access_key
      Azure.storage_account_name   = "ampimages"
    end

    def subscription_id
      creds_dbag["azure"]["publish_settings"]["subscription_id"]
    end

    def management_certificate
      Base64.decode64(creds_dbag["azure"]["publish_settings"]["management_certificate"])
    end

    def storage_access_key
      creds_dbag["azure"]["publish_settings"]["storage_access_key"]
    end

    def creds_data_bag_file
      # Something funky is going on in Inspec where __FILE__ reports we're at cookbook_root/libraries rather than
      # cookbook_root/test/shared_tests/smoke/libraries
      File.join(File.expand_path(File.dirname(__FILE__)), "..", "data_bags", "marketplace_image", "publishing_credentials.json")
    end

    def creds_dbag
      @creds_dbag ||= JSON.load(File.read(creds_data_bag_file))
    end
  end
end
