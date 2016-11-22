def column_size
  max = 25
  @found_images.keys.each do |key|
    max = key.size if key.size > max
  end

  max + 1
end

builders = JSON.load(file("/tmp/marketplace_image_manifest.json").content)

@found_images = {}

builders["aws"].each do |ami_name|
  ami = aws_marketplace_image(ami_name)

  @found_images[ami_name] = ami.image_id

  describe ami do
    it { should exist }
  end
end

unless @found_images.empty?
  puts ""
  puts format("%-#{column_size}s %s", "PACKER BUILDER NAME", "AMI ID")
  @found_images.each do |builder_name, ami_id|
    puts format("%-#{column_size}s %s", builder_name, ami_id)
  end
  puts ""
end
