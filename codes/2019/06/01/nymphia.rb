group('mozami.me (AWS)') {
  use_gateway 'gw.mozami.me'

  default_params {
    user 'mozamimy'
    port 22
    forward_agent 'yes'
    use_identify_file :usagoya
  }

  host('workbench-001.apne1.aws.mozami.me') {
    hostname 'workbench-001.apne1.aws.mozami.me'
    strict_host_key_checking 'no'
    user_known_hosts_file '/dev/null'
  }

  host('*.apne1.aws.mozami.me')
  host('10.33.*')
}
