
describe service('httpd') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe port(443) do
  it { should be_listening }
end

describe port(22) do
  it { should be_listening }
end

describe file('/etc/httpd/conf.d/welcome.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/ssl.conf') do
  it { should_not exist }
end

describe file('/etc/httpd/conf.d/autoindex.conf') do
  it { should_not exist }
end


describe file('/etc/httpd/conf.modules.d/00-base.conf') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should match '^#LoadModule info_module modules/mod_info.so' }
  its('content') { should match '^#LoadModule userdir_module modules/mod_userdir.so' }
  its('content') { should match '^#LoadModule autoindex_module modules/mod_autoindex.so' }
end


describe http('http://localhost/server-status') do
  its('status') { should cmp 200 }
end

describe http('https://localhost/server-status', ssl_verify: false) do
  its('status') { should cmp 403 }
end

ip = command("hostname -I").stdout.strip

describe http('http://' +ip +'/server-status') do
  its('status') { should cmp 403 }
end

describe http('https://' +ip +'/server-status', ssl_verify: false) do
  its('status') { should cmp 403 }
end

# dummy test a postive to avoid false negatives for disabled modules
describe command("sudo httpd -t -D DUMP_MODULES") do
  its('stdout') { should match '^ http_module \((static|shared)\)' }
  its('exit_status') { should eq 0 }

end

describe command("sudo httpd -t -D DUMP_MODULES") do
  its('stdout') { should_not match '^\sinfo_module' }
  its('exit_status') { should eq 0 }
end

describe command("sudo httpd -t -D DUMP_MODULES") do
  its('stdout') { should_not match '^\suserdir_module' }
  its('exit_status') { should eq 0 }
end

describe command("sudo httpd -t -D DUMP_MODULES") do
  its('stdout') { should_not match '^\sautoindex_module' }
  its('exit_status') { should eq 0 }
end
