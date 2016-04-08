require "aws-sdk"

module Inspec::Resources
  class AwsMarketplaceImage < Inspec.resource(1)
    name "aws_marketplace_image"
    desc "Resource for inspecting AWS AMIs by name for Chef Marketplace"
    example <<-EOH
describe aws_image_name("name_of_my_ami") do
  it { should exist }
end
EOH

    attr_reader :ami, :ami_name, :results

    def initialize(ami_name)
      @ami_name = ami_name
      @results  = ec2.describe_images(filters: [{ name: "name", values: [ami_name] }]).images
      @ami      = @results.first
    end

    def to_s
      "AWS AMI Name #{ami_name}"
    end

    def exists?
      results.count == 1
    end

    def image_id
      ami.image_id
    end

    private

    def aws_credentials
      @aws_credentials ||= Aws::Credentials.new(creds_dbag["aws"]["secret_key_id"], creds_dbag["aws"]["secret_access_key"])
    end

    def ec2
      @ec2 ||= Aws::EC2::Client.new(region: "us-east-1", credentials: aws_credentials)
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
