shared_examples 'ovirt::engine::install' do
  it do
    should contain_package('ovirt-engine').with({
      :ensure   => 'installed',
    })
  end

  it { should_not contain_package('ovirt-engine-setup-plugin-allinone') }
  it { should_not contain_package('ovirt-engine-reports') }
  it { should_not contain_package('ovirt-engine-dwh') }

  context 'when config_allinone => true' do
    let(:params) {{ :config_allinone => true }}

    it do
      should contain_package('ovirt-engine-setup-plugin-allinone').with({
        :ensure   => 'installed',
        :require  => 'Package[ovirt-engine]',
      })
    end
  end

  context 'when enable_reports => true' do
    let(:params) {{ :enable_reports => true }}

    it do
      should contain_package('ovirt-engine-reports').with({
        :ensure   => 'installed',
        :require  => 'Package[ovirt-engine]',
        #:notify   => 'Exec[engine-setup]',
      })
    end

    it do
      should contain_package('ovirt-engine-dwh').with({
        :ensure   => 'installed',
        :require  => 'Package[ovirt-engine]',
        #:notify   => 'Exec[engine-setup]',
      })
    end
  end
end
