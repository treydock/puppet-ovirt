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

  it_behaves_like 'ovirt::engine::postgresql'
  it_behaves_like 'ovirt::engine::install'
  it_behaves_like 'ovirt::engine::config'
  it_behaves_like 'ovirt::engine::service'

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
        it 'should raise an error' do
          expect { should compile }.to raise_error(/is not a boolean/)
        end
      end
    end
  end
end
