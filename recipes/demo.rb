

include_recipe "lipstick::centos_patch"
include_recipe "lipstick::mysql"
include_recipe "lipstick::server"
include_recipe "lipstick::pseudo_hadoop"




%W{ 1 2 }.each do |i|
  execute "upload demo file #{i} to hdfs" do
    local_src = "#{node['lipstick']['git_checkout_directory']}/quickstart/#{i}.dat"
    hdfs_dest = "/user/#{node['lipstick']['demo_user']}/#{i}.dat"
    command "hadoop fs -put #{local_src} #{hdfs_dest}"
    user node['lipstick']['demo_user']
    not_if "hadoop fs -test -e #{hdfs_dest}"
  end
end

template "#{node['lipstick']['demo_home']}/pig.properties" do
  owner "#{node['lipstick']['demo_user']}"
  group "#{node['lipstick']['demo_user']}"
  variables ({
               :lipstick_url => node['lipstick']['demo_url']
             })
end

template "#{node['lipstick']['demo_home']}/run-example-pig-script.sh" do
  owner "#{node['lipstick']['demo_user']}"
  group "#{node['lipstick']['demo_user']}"
  variables ({
               :demo_home_dir => node['lipstick']['demo_home'],
               :git_checkout => node['lipstick']['git_checkout_directory'],
             })
  mode "0755"
end

