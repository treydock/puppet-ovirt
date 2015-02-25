shared_examples 'ovirt::engine::service' do
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
