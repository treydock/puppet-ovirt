shared_examples 'ovirt::engine::config' do
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
      'OVESETUP_ENGINE_CORE/enable=bool:True',
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
        'OVESETUP_AIO/configure=bool:True',
        'OVESETUP_AIO/storageDomainName=str:local_storage',
        'OVESETUP_AIO/storageDomainDir=str:/var/lib/images',
      ])
    end
  end

  context 'when notifier_mail_server => "mail.example.com"' do
    let(:params) {{ :notifier_mail_server => 'mail.example.com' }}

    it do
      should contain_shellvar('ovirt-engine-notifier MAIL_SERVER').with({
        :ensure   => 'present',
        :target   => '/etc/ovirt-engine/notifier/notifier.conf.d/99-local.conf',
        :variable => 'MAIL_SERVER',
        :value    => 'mail.example.com',
        :notify   => 'Service[ovirt-engine-notifier]',
      })
    end
  end

  context 'when enable_reports => true' do
    let(:params) {{ :enable_reports => true }}

    it 'sets reports and dwh values' do
      verify_contents(catalogue, 'ovirt-engine-setup.conf', [
        'OVESETUP_DWH_CORE/enable=bool:True',
        'OVESETUP_DWH_DB/database=str:ovirt_engine_history',
        'OVESETUP_DWH_DB/secured=bool:False',
        'OVESETUP_DWH_DB/host=str:localhost',
        'OVESETUP_DWH_DB/disconnectExistingDwh=none:None',
        'OVESETUP_DWH_DB/restoreBackupLate=bool:True',
        'OVESETUP_DWH_DB/user=str:ovirt_engine_history',
        'OVESETUP_DWH_DB/securedHostValidation=bool:False',
        'OVESETUP_DWH_DB/performBackup=none:None',
        'OVESETUP_DWH_DB/password=str:ovirt_engine_history',
        'OVESETUP_DWH_DB/port=int:5432',
        'OVESETUP_DWH_PROVISIONING/postgresProvisioningEnabled=bool:False',
        'OVESETUP_REPORTS_CORE/enable=bool:True',
        'OVESETUP_REPORTS_CONFIG/adminPassword=str:admin',
        'OVESETUP_REPORTS_DB/database=str:ovirt_engine_reports',
        'OVESETUP_REPORTS_DB/secured=bool:False',
        'OVESETUP_REPORTS_DB/host=str:localhost',
        'OVESETUP_REPORTS_DB/user=str:ovirt_engine_reports',
        'OVESETUP_REPORTS_DB/securedHostValidation=bool:False',
        'OVESETUP_REPORTS_DB/password=str:ovirt_engine_reports',
        'OVESETUP_REPORTS_DB/port=int:5432',
        'OVESETUP_REPORTS_PROVISIONING/postgresProvisioningEnabled=bool:False',
      ])
    end
  end
end
