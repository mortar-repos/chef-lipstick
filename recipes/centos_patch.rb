

template "/etc/sysconfig/iptables" do
  owner "root"
  group "root"
  mode "0600"
  variables ({
               :http_port => "8080",
               :jobtracker_port => "50030",
             })
  notifies :restart, "service[iptables]"
end

service "iptables" do
  action :nothing
end
