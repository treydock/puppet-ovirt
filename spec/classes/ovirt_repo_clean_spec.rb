require 'spec_helper'

describe 'ovirt::repo::clean' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::repo::clean') }
  it { should contain_class('ovirt') }

  it { should contain_file('/etc/yum.repos.d/ovirt-3.5-dependencies.repo').with_ensure('absent') }

end
