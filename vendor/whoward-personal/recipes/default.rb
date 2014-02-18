Packages = %w(
   amarok ffmpeg google-chrome-stable google-musicmanager-beta gimp graphviz
   heroku-toolbelt htop imagemagick inkscape iotop memcached mongodb 
   nginx openssh-server postgresql-9.3 postgresql-contrib-9.3 pgadmin3
   steam sublime-text terminator tree virtualbox-4.3 vlc wine1.7 meld
)

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

apt_repository "heroku-toolbelt" do
   uri "http://toolbelt.heroku.com/ubuntu"
   distribution './'
   key "https://toolbelt.heroku.com/apt/release.key"
end

apt_repository "valve-steam" do
   arch = case node['kernel']['machine']
      when 'x86_64' then 'amd64'
      when 'i686' then 'i386'
      else raise "unknown kernel machine: #{node['kernel']['machine']}"
   end

   uri "[arch=#{arch}] http://repo.steampowered.com/steam/"
   distribution "precise"
   components ["steam"]
   keyserver "keyserver.ubuntu.com"
   key "B05498B7"
end

apt_repository "virtualbox" do
   uri "http://download.virtualbox.org/virtualbox/debian"
   distribution node['lsb']['codename']
   components ["contrib"]
   key "http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc"
end

apt_repository "ppa-webupd8team-sublime-text-2" do
   uri "http://ppa.launchpad.net/webupd8team/sublime-text-2/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "EEA14886"
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

apt_repository "ppa-john-severinsson-ffmpeg" do
   uri "http://ppa.launchpad.net/jon-severinsson/ffmpeg/ubuntu"
   distribution node['lsb']['codename']
   components ["main"]
   keyserver "keyserver.ubuntu.com"
   key "CFCA9579"
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

apt_repository "ppa-ondrej-mysql-5.6" do
   uri "http://ppa.launchpad.net/~ondrej/mysql-5.6/ubuntu"
   distribution node['lsb']['codename']
   components ['main']
   keyserver "keyserver.ubuntu.com"
   key "E5267A6C"
end

# PostgreSQL official APT repository
apt_repository "pgdg" do
   uri "http://apt.postgresql.org/pub/repos/apt/"
   distribution case node['lsb']['release']
      when /^13\.\d{2}$/ then "precise-pgdg"
      when /^14\.\d{2}$/ then "trusty-pgdg"
   end
   components ["main"]
   key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
end

Packages.each do |package_name|
   package(package_name) { action :install }
end

# SSH Keys
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
