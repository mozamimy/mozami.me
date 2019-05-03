identity_file :private, '~/.ssh/id_rsa.1'

host 'alice', 'my server on VPS' do
  hostname 'alice.example.com'
  user 'alice'
  port 4321
  use_identify_file :private
end

load 'other_nymphia_file.rb'
