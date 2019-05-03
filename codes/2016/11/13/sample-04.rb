identity_file :company, '~/.ssh/id_rsa.company'
identity_file :company_gateway, '~/.ssh/id_rsa.company.gw'

gateway 'company.gateway' do
  hostname 'gw.example.com'
  user 'alice'
  port 19822
end

group 'company.ap-northeast-1' do
  use_gateway 'company.gateway'

  default_params do
    check_host_ip 'no'
    strict_host_key_checking 'no'
    user 'alice'
    port 9822
    use_identify_file :company, :company_gateway
  end

  host '*.apne.aws.example.com'

  host 'alice.apne.aws.example.com' do
    hostname '10.16.16.16'
    user 'white_rabbit'
    port 7777
  end
end
