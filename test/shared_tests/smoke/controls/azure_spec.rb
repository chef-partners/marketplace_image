builders = JSON.load(file("/tmp/marketplace_image_manifest.json").content)

builders["azure"].each do |blob_name|
  describe azure_marketplace_image(blob_name) do
    it { should exist }
  end
end
