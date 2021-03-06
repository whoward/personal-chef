Packages = %w(
   amarok libav-tools google-chrome-stable google-musicmanager-beta google-talkplugin
   gimp imagemagick inkscape memcached mongodb nginx openssh-server vlc
   insync ruby-dev redis-server elasticsearch suld-driver-4.00.39
   virtualbox-5.0
)

# Tools
Packages << %w(graphviz heroku-toolbelt htop iotop terminator tree nodejs phantomjs android-studio meld)

# MySQL
#Packages << %w(mysql-server-5.6 libmysqlclient-dev)

# MariaDB
Packages << %w(mariadb-server mariadb-client)

# PostgreSQL
Packages << %w(postgresql-9.4 postgresql-contrib-9.4 libpq-dev) # pgadmin3

# Java
Packages << %w(oracle-java9-installer oracle-java9-set-default)

# virtualization packages, for the android emulator mostly
Packages << %w(qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils)

# calculate the debian architecture name from the node attributes
arch = case node['kernel']['machine']
   when 'x86_64' then 'amd64'
   when 'i686' then 'i386'
   else raise "unknown kernel machine: #{node['kernel']['machine']}"
end

apt_repository "google-chrome" do
   uri "http://dl.google.com/linux/deb/"
   distribution "stable"
   components ["main"]
   key "https://dl-ssl.google.com/linux/linux_signing_key.pub"
end

apt_repository "google-music-manager" do
   uri "http://dl.google.com/linux/musicmanager/deb/"
   distribution "stable"
   components ["main"]
   key "https://dl-ssl.google.com/linux/linux_signing_key.pub"
end

apt_repository "google-talkplugin" do
   uri "http://dl.google.com/linux/talkplugin/deb/"
   distribution "stable"
   components ["main"]
   key "https://dl-ssl.google.com/linux/linux_signing_key.pub"
end

apt_repository "heroku-toolbelt" do
   uri "http://toolbelt.heroku.com/ubuntu"
   distribution './'
   key "https://toolbelt.heroku.com/apt/release.key"
end

apt_repository "valve-steam" do
   uri "[arch=#{arch}] http://repo.steampowered.com/steam/"
   distribution "precise"
   components ["steam"]
   keyserver "keyserver.ubuntu.com"
   key "B05498B7"
end

apt_repository "virtualbox" do
   uri "http://download.virtualbox.org/virtualbox/debian"
   distribution "utopic" # node['lsb']['codename']
   components ["contrib"]
   key "http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc"
end

apt_repository "ppa-nginx-stable" do
   uri "http://ppa.launchpad.net/nginx/stable/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "C300EE8C"
end

# includes, among other things, Amarok
apt_repository "ppa-kubuntu-ppa-backports" do
   uri "http://ppa.launchpad.net/kubuntu-ppa/backports/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "8AC93F7A"
end

apt_repository "ppa-otto-kesselgulasch-gimp" do
   uri "http://ppa.launchpad.net/otto-kesselgulasch/gimp/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "614C4B38"
end

apt_repository "ppa-ubuntu-wine-ppa" do
   uri "http://ppa.launchpad.net/ubuntu-wine/ppa/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "F9CB8DB0"
end

apt_repository "ppa-paolorotolo-android-studio" do
   uri "http://ppa.launchpad.net/paolorotolo/android-studio/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "7B9B74AA"
end

apt_repository "ppa-webupd8team-atom" do
   uri "http://ppa.launchpad.net/webupd8team/atom/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "EEA14886"
end

apt_repository "ppa-webupd8team-java" do
   uri "http://ppa.launchpad.net/webupd8team/java/ubuntu"
   distribution node['lsb']['codename']
   components ['main']
   keyserver 'keyserver.ubuntu.com'
   key 'EEA14886'
end

# PostgreSQL official APT repository
apt_repository "pgdg" do
   uri "http://apt.postgresql.org/pub/repos/apt/"
   distribution case node['lsb']['release']
      when /^13\.\d{2}$/ then "precise-pgdg"
      when /^14\.\d{2}$/ then "trusty-pgdg"
      when /^15\.\d{2}$/ then "utopic-pgdg"
   end
   components ["main"]
   key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
end

# Commercial Google Drive client for Linux
apt_repository "insync" do
   uri "http://apt.insynchq.com/ubuntu"
   distribution node['lsb']['codename']
   components ['non-free', 'contrib']
   key "https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key"
end

# Elasticsearch 1.1.x
apt_repository "elasticsearch" do
   uri "http://packages.elasticsearch.org/elasticsearch/1.1/debian"
   components ['stable', 'main']
   key "http://packages.elasticsearch.org/GPG-KEY-elasticsearch"
end

# Samsung Unified Linux Print Driver Repository
apt_repository "suldr" do
   uri "http://www.bchemnet.com/suldr/"
   distribution "debian"
   components ['extra']
   key "http://www.bchemnet.com/suldr/suldr.gpg"
end

# libvpx1 for virtualbox to work
if node['platform'] == 'ubuntu' && node['platform_version'] == '15.10'
  remote_file "/tmp/libvpx1_#{arch}.deb" do
    source "http://security.ubuntu.com/ubuntu/pool/main/libv/libvpx/libvpx1_1.0.0-1_#{arch}.deb"
    mode 0644
    if arch == 'amd64'
      checksum '222fb543fe830645b1ba3a4e2cb1ab0cd5a72a2e21af7fc64724072c263fb9c2'
    else
      checksum '740fa7c179202f4d1ec27ef8fa18a8ec09c00b136b742bf927e7c2318c31889b'
    end
  end

  dpkg_package 'libvpx1' do
    source "/tmp/libvpx1_#{arch}.deb"
    action :install
  end
end

# Install all regular packages
Packages.each do |package_name|
   package(package_name) { action :install }
end

# SSH Keys

directory "/home/will/.ssh" do
   owner  "will"
   group  "will"
   mode   "0700"
   action :create
end

data_bag("keys").each do |key|
   data = Chef::EncryptedDataBagItem.load("keys", key)

   # private key
   file "/home/will/.ssh/id_#{key}" do
      owner   "will"
      group   "will"
      mode    "0600"
      action  :create
      content data["private"]
   end

   # public key
   file "/home/will/.ssh/id_#{key}.pub" do
      owner   "will"
      group   "will"
      mode    "0600"
      action  :create
      content data["public"]
   end
end

# SSH Configuration File
file "/home/will/.ssh/config" do
  owner   "will"
  group   "will"
  mode    "0600"
  action  :create
  content Chef::EncryptedDataBagItem.load("config", "ssh-client")["file"]
end

# Dotfiles repository
git "/home/will/.dotfiles" do
   repository "git://github.com/whoward/dotfiles.git"
   reference "master"
   action :sync
   user  "will"
   group "will"
end

# symlink important files idempotently for .bashrc
execute "bashrc-link-dotfiles" do
   command %Q{echo "source /home/will/.dotfiles/bashrc" >> /home/will/.bashrc}
   not_if  %Q{cat /home/will/.bashrc | grep "source /home/will/.dotfiles/bashrc"}
end

execute "bashrc-link-rvm" do
   command %Q{echo "source /home/will/.rvm/scripts/rvm" >> /home/will/.bashrc}
   not_if  %Q{cat /home/will/.bashrc | grep "source /home/will/.rvm/scripts/rvm"}
end

# symlink important files idempotently for .bashrc
execute "bash_profile-link-dotfiles" do
   command %Q{echo "source /home/will/.dotfiles/bashrc" >> /home/will/.bash_profile}
   not_if  %Q{cat /home/will/.bash_profile | grep "source /home/will/.dotfiles/bashrc"}
end

execute "bash_profile-link-rvm" do
   command %Q{echo "source /home/will/.rvm/scripts/rvm" >> /home/will/.bash_profile}
   not_if  %Q{cat /home/will/.bash_profile | grep "source /home/will/.rvm/scripts/rvm"}
end

# Add user to virtualization groups
group "kvm" do
   action :modify
   members "will"
   append true
end

group "libvirtd" do
   action :modify
   members "will"
   append true
end
