require 'spec_helper'

describe 'ovirt' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt') }
  it { should contain_class('ovirt::params') }

  context "when version => '3.3'" do
    let(:params) {{ :version => '3.3' }}
    it { expect { should create_class('ovirt') }.to raise_error(Puppet::Error, /Only version 3.4 is supported/) }
  end
end
