identity_file :private, '~/.ssh/id_rsa.1'

my_server_port = 4321

host 'alice', 'my server on VPS' do
  hostname 'alice.example.com'
  user 'alice'
  port my_server_port
  use_identify_file :private
end
