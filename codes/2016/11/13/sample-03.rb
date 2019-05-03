identity_file :company_gateway, '~/.ssh/id_rsa.company.gw'

proxy 'awsproxy.company.apne1' do
  hostname 'gw.apne1.example.com'
  user 'alice'
  port 19822
  use_identify_file :company_gateway

  # SOCKS proxy
  dynamic_forward 23921

  # ssh tunnels
  local_forward 'mysql-server', {
    'localhost' => 13306,
    'mysql.apne.aws.example.com' => 3306,
  }

  local_forward 'ldap', {
    'localhost' => 10389,
    'ldap.apne.aws.example.com' => 398,
  }
end
