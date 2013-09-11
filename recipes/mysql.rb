

include_recipe "mysql::server"

# Create the lipstick database if it doesn't exist yet
execute "Create lipstick database" do
  command %Q{mysql --user=root --password=#{node['mysql']['server_root_password']} --execute="CREATE DATABASE IF NOT EXISTS lipstick"}
  creates "#{node['mysql']['data_dir']}/lipstick"
end
