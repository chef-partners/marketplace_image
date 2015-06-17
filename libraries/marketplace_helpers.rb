# Some helpers
module MarketplaceHelpers
  def self.user_directories
    Etc::Passwd.each_with_object({}) do |user, memo|
      next if %w(halt sync shutdown).include?(user.name) ||
              user.shell =~ %r{(/sbin/nologin|/bin/false)}
      memo[user.name] = user.dir
    end
  end

  def self.system_ssh_keys
    %w(key key.pub dsa_key dsa_key.pub rsa_key.pub rsa_key).map do |key|
      "/etc/ssh/ssh_host_#{key}"
    end
  end

  def self.sudoers
    Dir['/etc/sudoers.d/*']
  end
end
