

remote_file "/tmp/hadoop-1.0.3-1.x86_64.rpm" do
  source "http://archive.apache.org/dist/hadoop/core/hadoop-1.0.3/hadoop-1.0.3-1.x86_64.rpm"
  checksum "03adcf79f9e4c524a8669290f69245df5490181c726c0e9326442894ecb3ace0"
  # notifies :run, "rpm_package[hadoop]"
end

rpm_package "hadoop" do
  source "/tmp/hadoop-1.0.3-1.x86_64.rpm"
end

execute "configure single node hadoop cluster" do
  command "/usr/sbin/hadoop-setup-single-node.sh"
  creates "/etc/hadoop"
  environment ({
                 'AUTOMATED' => '1'
               })
end


# package "curl"
# key_url = "http://archive.cloudera.com/cdh4/#{node[:lsb][:id].downcase}/#{node[:lsb][:codename]}/amd64/cdh/archive.key"
# execute "curl -s #{key_url} | apt-key add -" do
#   not_if "apt-key list|grep 'Cloudera Apt Repository'"
#   notifies :run, resources("execute[apt-get update]"), :immediately
# end


# package "hadoop-0.20-conf-pseudo" do
#   action :install
#   notifies :run, "execute[format hdfs]", :immediately
# end

# The default configuration that comes with the rpms
# has some errors in it
template "/etc/hadoop/core-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
end

template "/etc/hadoop/mapred-site.xml" do
  owner "root"
  group "hadoop"
  mode "0644"
end

# namenode daemon wasn't starting due to this directory not existing
directory "/tmp/hadoop-hdfs/dfs/name" do
  owner "hdfs"
  group "hadoop"
  action :create
  recursive true
  mode "0755"
end
directory "/tmp/hadoop-hdfs/dfs/data" do
  owner "hdfs"
  group "hadoop"
  action :create
  recursive true
  mode "0755"
end


# This should only ever happen once
execute "format hdfs" do
  command "yes Y | /etc/init.d/hadoop-namenode format"
  # command "hadoop namenode -format"
  # user "hdfs"
  creates "/tmp/hadoop-hdfs/dfs/name/current/VERSION"
end

# %w{namenode datanode secondarynamenode}.each do |d|
#   service "hadoop-hdfs-#{d}" do
#     action :start
#   end
# end

%W{namenode secondarynamenode datanode}.each do |d|
  service "hadoop-#{d}" do
    action [ :start, :enable ]
  end
end


# Need to be created/have permissions set before starting
# the mapred daemons or they will fail to start, but also
# needs to run after hdfs daemons start or they wont' be
# able to issue dfs commands.
bash "create tmp directories" do
  user "hdfs"
  code <<-EOH
  hadoop fs -mkdir -p /tmp
  hadoop fs -chmod -R 777 /tmp
  hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
  hadoop fs -chmod 777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
  hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred
  hadoop fs -ls -R /
  EOH
end

# bash "create user directories" do
#   user "hdfs"
#   code <<-EOH
#   hadoop fs -mkdir -p /user/vagrant
#   hadoop fs -chown vagrant /user/vagrant
#   EOH
# end

# %w{jobtracker tasktracker}.each do |d|
#   service "hadoop-0.20-mapreduce-#{d}" do
#     action [ :start, :enable ]
#   end
# end



%W{jobtracker tasktracker historyserver}.each do |d|
  service "hadoop-#{d}" do
    action [ :start, :enable ]
  end
end

execute "create hdfs user account" do
  command "/usr/sbin/hadoop-create-user.sh -u vagrant"
end


bash "create demo user tmp directories" do
  user_staging_directory = "/tmp/hadoop-mapred/mapred/staging/#{node['lipstick']['demo_user']}"
  user "hdfs"
  code <<-EOH
  hadoop fs -mkdir -p #{user_staging_directory}/.staging
  hadoop fs -chmod 700 #{user_staging_directory}/.staging
  hadoop fs -chown -R #{node['lipstick']['demo_user']} #{user_staging_directory}
  EOH
end


