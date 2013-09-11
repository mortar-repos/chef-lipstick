# Installs the Lipstick server behind a tomcat instance


%W{graphviz unzip}.each{ |p|
  package p do
    action :install
  end
}

include_recipe "git"
include_recipe "java"
include_recipe "tomcat"

template "/etc/lipstick.properties" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0600"
  variables({
              :db_username => "root",
              :db_password => node['mysql']['server_root_password'],
              :db_host => node['mysql']['bind_address'],
              :db_port => node['mysql']['port']
            })
  notifies :restart, "service[tomcat]", :delayed
end

directory "#{node['lipstick']['git_checkout_directory']}" do
  action :create
  recursive true
end
git "#{node['lipstick']['git_checkout_directory']}" do
  repository "#{node['lipstick']['git_repo']}"
  reference "#{node['lipstick']['git_ref']}"
  action :sync
  notifies :run, "execute[build war file for tomcat]", :immediately
end

staging_war_file = "#{node['lipstick']['git_checkout_directory']}/build/lipstick-1.0.war"
execute "build war file for tomcat" do
  command "./gradlew"
  cwd "#{node['lipstick']['git_checkout_directory']}"
  environment ({'JAVA_HOME' => node['java']['java_home']})
  action File.exists?(staging_war_file) ? :nothing : :run
  notifies :run, "execute[install war file]", :immediately
end

running_war_file = "#{node["tomcat"]["webapp_dir"]}/lipstick-1.0.war"
execute "install war file" do
  command "cp #{staging_war_file} #{running_war_file} "
  action File.exists?(running_war_file) ? :nothing : :run
  notifies :restart, "service[tomcat]", :delayed
end
