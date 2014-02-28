require 'spec_helper'

describe 'ovirt::engine' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::engine') }
  it { should contain_class('ovirt::params') }
  it { should contain_class('ovirt') }

  it do
    should contain_package('ovirt-engine').with({
      'ensure'    => 'installed',
      'require'   => 'Package[ovirt-release]',
      'before'    => 'File[ovirt-engine-setup.conf]',
    })
  end

  it do
    should contain_file('ovirt-engine-setup.conf').with({
      'ensure'  => 'present',
      'path'    => '/var/lib/ovirt-engine/setup/answers/ovirt-engine-setup.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0600',      
    })
  end

  it do
    content = catalogue.resource('file', 'ovirt-engine-setup.conf').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      '[environment:default]',
      'OVESETUP_CORE/engineStop=none:None',
      'OVESETUP_DIALOG/confirmSettings=bool:True',
      'OVESETUP_DB/database=str:engine',
      'OVESETUP_DB/fixDbViolations=none:None',
      'OVESETUP_DB/secured=bool:False',
      'OVESETUP_DB/host=str:localhost',
      'OVESETUP_DB/user=str:engine',
      'OVESETUP_DB/securedHostValidation=bool:False',
      'OVESETUP_DB/password=str:engine',
      'OVESETUP_DB/port=int:5432',
      'OVESETUP_SYSTEM/nfsConfigEnabled=bool:True',
      'OVESETUP_SYSTEM/memCheckEnabled=bool:True',
      'OVESETUP_PKI/organization=str:example.com',
      'OVESETUP_CONFIG/isoDomainName=str:ISO_DOMAIN',
      'OVESETUP_CONFIG/isoDomainMountPoint=str:/var/lib/exports/iso',
      'OVESETUP_CONFIG/adminPassword=str:admin',
      'OVESETUP_CONFIG/applicationMode=str:both',
      'OVESETUP_CONFIG/firewallManager=str:iptables',
      'OVESETUP_CONFIG/updateFirewall=bool:False',
      'OVESETUP_CONFIG/websocketProxyConfig=bool:True',
      'OVESETUP_CONFIG/fqdn=str:foo.example.com',
      'OVESETUP_CONFIG/storageType=str:nfs',
      'OVESETUP_PROVISIONING/postgresProvisioningEnabled=bool:False',
      'OVESETUP_APACHE/configureRootRedirection=bool:True',
      'OVESETUP_APACHE/configureSsl=bool:True',
      'OSETUP_RPMDISTRO/requireRollback=none:None',
      'OSETUP_RPMDISTRO/enableUpgrade=none:None',
      'OVESETUP_AIO/configure=none:None',
      'OVESETUP_AIO/storageDomainDir=none:None',
    ]
  end

  it do
    should contain_service('ovirt-engine').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => nil,
      'subscribe'   => 'Exec[engine-setup]',
    })
  end

  it do
    should contain_service('ovirt-websocket-proxy').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'require'     => nil,
      'subscribe'   => 'Exec[engine-setup]',
    })
  end

  it do
    should contain_exec('engine-setup').with({
      'refreshonly' => 'true',
      'path'        => '/usr/bin/:/bin/:/sbin:/usr/sbin',
      'command'     => "yes 'Yes' | engine-setup --config-append=/var/lib/ovirt-engine/setup/answers/ovirt-engine-setup.conf",
      'timeout'     => '0',
      'subscribe'   => 'Package[ovirt-engine]',
      'require'     => 'File[ovirt-engine-setup.conf]',
    })
  end

  context 'when nfs_config_enabled => false' do
    let(:params) {{ :nfs_config_enabled => false }}
    it do
      verify_contents(catalogue, 'ovirt-engine-setup.conf', [
        'OVESETUP_SYSTEM/nfsConfigEnabled=bool:False',
        'OVESETUP_CONFIG/isoDomainName=none:None',
        'OVESETUP_CONFIG/isoDomainMountPoint=none:None',
      ])
    end
  end

  context 'when config_allinone => true' do
    let(:params) {{ :config_allinone => true, :local_storage_path => '/foo', :superuser_pass => 'bar' }}

    it do
      should contain_package('ovirt-engine-setup-plugin-allinone').with({
        'ensure'    => 'installed',
        'require'   => 'Package[ovirt-engine]',
        'before'    => 'File[ovirt-engine-setup.conf]',
      })
    end

    it do
      verify_contents(catalogue, 'ovirt-engine-setup.conf', [
        'CONFIG_ALLINONE=yes',
        'STORAGE_PATH=/foo',
        'SUPERUSER_PASS=bar',
      ])
    end
  end

  # Test boolean validation
  [
    'manage_postgresql_server',
    'config_allinone',
    'nfs_config_enabled',
    'manage_firewall',
    'websocket_proxy_config',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('ovirt::engine') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
