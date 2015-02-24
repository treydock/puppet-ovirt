require 'spec_helper'

describe 'ovirt::engine' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::engine') }
  it { should contain_class('ovirt::params') }

  it { should contain_anchor('ovirt::engine::start').that_comes_before('Class[ovirt::repo]') }
  it { should contain_class('ovirt::repo').that_comes_before('Class[ovirt::engine::postgresql]') }
  it { should contain_class('ovirt::engine::postgresql').that_comes_before('Class[ovirt::engine::install]') }
  it { should contain_class('ovirt::engine::install').that_comes_before('Class[ovirt::engine::config]') }
  it { should contain_class('ovirt::engine::config').that_comes_before('Class[ovirt::engine::service]') }
  it { should contain_class('ovirt::engine::service').that_comes_before('Anchor[ovirt::engine::end]') }
  it { should contain_anchor('ovirt::engine::end') }

  describe 'ovirt::engine::postgresql' do
    
  end

  describe 'ovirt::engine::install' do
    it do
      should contain_package('ovirt-engine').with({
        :ensure   => 'installed',
      })
    end

    it { should_not contain_package('ovirt-engine-setup-plugin-allinone') }

    context 'when config_allinone => true' do
      let(:params) {{ :config_allinone => true }}

      it do
        should contain_package('ovirt-engine-setup-plugin-allinone').with({
          :ensure   => 'installed',
          :require  => 'Package[ovirt-engine]',
        })
      end
    end
  end

  describe 'ovirt::engine::config' do
    it do
      should contain_file('ovirt-engine-setup.conf').with({
        :ensure   => 'present',
        :path     => '/var/lib/ovirt-engine/setup/answers/ovirt-engine-setup.conf',
        :owner    => 'root',
        :group    => 'root',
        :mode     => '0600',      
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
      should contain_exec('engine-setup').with({
        :refreshonly  => 'true',
        :path         => '/usr/bin/:/bin/:/sbin:/usr/sbin',
        :command      => "yes 'Yes' | engine-setup --config-append=/var/lib/ovirt-engine/setup/answers/ovirt-engine-setup.conf",
        :timeout      => '0',
        :subscribe    => 'Package[ovirt-engine]',
        :require      => 'File[ovirt-engine-setup.conf]',
      })
    end

    it { should_not contain_shellvar('ovirt-engine-notifier MAIL_SERVER') }

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
      let(:params) {{ :config_allinone => true }}

      it do
        verify_contents(catalogue, 'ovirt-engine-setup.conf', [
          'CONFIG_ALLINONE=yes',
        ])
      end
    end

    context 'when notifier_mail_server => "mail.example.com"' do
      let(:params) {{ :notifier_mail_server => 'mail.example.com' }}

      it do
        should contain_shellvar('ovirt-engine-notifier MAIL_SERVER').with({
          :ensure   => 'present',
          :target   => '/usr/share/ovirt-engine/services/ovirt-engine-notifier/ovirt-engine-notifier.conf',
          :variable => 'MAIL_SERVER',
          :value    => 'mail.example.com',
          :notify   => 'Service[ovirt-engine-notifier]',
        })
      end
    end
  end

  describe 'ovirt::engine::service' do
    it do
      should contain_service('ovirt-engine').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
      })
    end

    it do
      should contain_service('ovirt-websocket-proxy').with({
        :ensure     => 'running',
        :enable     => 'true',
        :hasstatus  => 'true',
        :hasrestart => 'true',
        :require    => 'Service[ovirt-engine]',
      })
    end

    it { should_not contain_service('ovirt-engine-notifier') }

    context 'when notifier_mail_server => "mail.example.com"' do
      let(:params) {{ :notifier_mail_server => 'mail.example.com' }}

      it do
        should contain_service('ovirt-engine-notifier').with({
          :ensure     => 'running',
          :enable     => 'true',
          :hasstatus  => 'true',
          :hasrestart => 'true',
          :require    => 'Service[ovirt-engine]',
        })
      end
    end
  end

  describe 'validations' do
    # Test boolean validation
    [
      :manage_postgresql_server,
      :config_allinone,
      :nfs_config_enabled,
      :manage_firewall,
      :websocket_proxy_config,
      :storeconfigs_enabled,
    ].each do |param|
      context "with #{param} => 'foo'" do
        let(:params) {{ param.to_sym => 'foo' }}
        it { expect { should create_class('ovirt::engine') }.to raise_error(Puppet::Error, /is not a boolean/) }
      end
    end
  end
end
