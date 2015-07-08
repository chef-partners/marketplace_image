require 'optparse'
require 'ostruct'
require 'highline/import'
require 'chef/json_compat'
require 'ohai/system'

add_command_under_category 'marketplace-setup', 'marketplace', 'Set up the Chef Server Marketplace Appliance', 2 do
  options = OpenStruct.new

  OptionParser.new do |opts|
    opts.banner = 'Usage: chef-server-ctl marketplace-setup [options]'

    opts.on('-y', '--yes', 'Agree to the Chef End User License Agreement') do
      options.agree_to_eula = true
    end

    opts.on('-u USERNAME', '--username USERNAME', String, 'Your Admin username') do |username|
      options.username = username
    end

    opts.on('-p PASSWORD', '--password PASSWORD', String, 'Your password') do |password|
      options.password = password
    end

    opts.on('-f FIRSTNAME', '--firstname FIRSTNAME', String, 'Your first name') do |first_name|
      options.first_name = first_name
    end

    opts.on('-l LASTNAME', '--lastname LASTNAME', String, 'Your last name') do |last_name|
      options.last_name = last_name
    end

    opts.on('-e EMAIL', '--email EMAIL', String, 'Your email address') do |email|
      options.email = email
    end

    opts.on('-o ORGNAME', '--org ORGNAME', String, 'Your organization name') do |org|
      options.organization = org
    end

    opts.on('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end.parse!(ARGV)

  MarketplaceSetup.setup(options, self)
end

# Setup the Marketplace Appliance
class MarketplaceSetup
  REQUIRED_OPTIONS = %w(first_name last_name username email organization password).freeze

  def self.setup(options, ctl_context)
    MarketplaceSetup.new(options, ctl_context).setup
  end

  attr_accessor :options, :required_options

  def initialize(options, ctl_context)
    @options = options
    @ctl_context = ctl_context
  end

  def setup
    run_validation_hook
    verify_options
    agree_to_eula
    update_fqdn
    reconfigure_chef_server
    create_default_user
    create_default_org
    reconfigure_webui
    reconfigure_reporting
    redirect_to_webui
  end

  private

  # Use omnibus-ctl methods if they're available
  def method_missing(meth, *args, &block)
    @ctl_context.respond_to?(meth) ? @ctl_context.send(meth, *args, &block) : super
  end

  # Some marketplaces have ways for the instance to determine if the instance
  # is running a paid image.  At build time we'll drop a validatation file
  # onto the filesystem that implements a class that will do the validations.
  def run_validation_hook
    hook_file = '/opt/opscode/embedded/service/omnibus-ctl/marketplace-validation.rb'
    return unless ::File.exist?(hook_file)
    ::Kernel.load(hook_file)
    MarketplaceValidation.validate
  end

  def verify_options
    REQUIRED_OPTIONS.each do |opt|
      next if options.send(opt)
      if opt == 'password'
        p1 = ask('Please enter your password:') { |c| c.echo = '*' }
        p2 = ask('Please enter your password again:') { |c| c.echo = '*' }
        if p1 == p2
          options[opt] = p1
        else
          puts 'Your passwords did not match'
          redo
        end
      elsif opt == 'organization'
        orgname = ask('Please enter an orgname(Only lowercase):') do |o|
          o.case = :down
          o.validate = /\A[a-z0-9][a-z0-9_-]{0,254}\Z/
        end
        options[opt] = orgname
      else
        options[opt] = ask("Please enter your #{opt}:")
      end
    end
  end

  def agree_to_eula
    return if options.agree_to_eula
    msg = 'By continuing you agree to be held to the terms of the '
    msg << 'Chef Software, Inc. License Agreement, as detailed here: '
    msg << "https://www.chef.io/online-master-agreement/\n"
    msg << 'Type \'yes\' if you agree'

    unless ask(msg) =~ /yes/i
      puts 'You must agree to the Chef Software, Inc License Agreement in order to continue.'
      exit 1
    end
  end

  def ohai
    @ohai ||= Ohai::System.new.all_plugins(%w(cloud_v2)).first
  end

  def update_fqdn
    return unless ohai.data['cloud_v2']

    api_fqdn =
      if ohai.on_gce?
        ohai.data['cloud_v2']['public_ipv4']
      elsif ohai.on_azure?
        "#{ohai.data['public_hostname']}.cloudapp.net"
      elsif ohai.on_ec2?
        ohai.data['cloud_v2']['public_hostname']
      end

    ::File.open('/etc/opscode/chef-server.rb', 'a') do |f|
      f.puts "api_fqdn '#{api_fqdn}'"
    end
  end

  def reconfigure_chef_server
    puts 'Please wait while we set up the Chef Server. This may take a few minutes to complete'
    run_command('chef-server-ctl reconfigure')
  end

  def reconfigure_reporting
    run_command('opscode-reporting-ctl reconfigure')
  end

  def reconfigure_webui
    run_command('opscode-manage-ctl reconfigure')
  end

  def create_default_user
    cmd = [
      'chef-server-ctl user-create',
      options['username'],
      options.first_name,
      options.last_name,
      options.email,
      options.password,
      '--filename /dev/null'
    ].join(' ')

    run_command(cmd)
  end

  def create_default_org
    retries = 0
    cmd = [
      'chef-server-ctl org-create',
      options.organization,
      options.organization,
      "-a #{options.username}"
    ].join(' ')

    until retries == 5
      break if run_command(cmd).success?
      retries += 1
      puts "retry (#{retries}/5) for: #{cmd}"
      sleep 2
    end
  end

  def redirect_to_webui
    chef_running = Chef::JSONCompat.parse(File.read('/etc/opscode/chef-server-running.json'))
    fqdn = chef_running['private_chef']['lb']['api_fqdn']
    msg = [
      "\n\nYou're all set!\n",
      "Next you'll want to log into the Chef Web Management console:",
      "https://#{fqdn}/login\n",
      'In order to use TLS we had to generate a self-signed certificate which',
      "might cause a warning in your browser, you can safely ignore it.\n",
      "Use your username '#{options.username}' instead of your email address to login\n",
      "After you've logged in you'll want to download the Starter Kit:",
      "https://#{fqdn}/organizations/#{options.organization}/getting_started\n"
    ].join("\n")

    puts(msg)
  end
end
