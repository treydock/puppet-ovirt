shared_examples 'ovirt::engine::postgresql' do
  it { should contain_class('postgresql::server') }

  it do
    should contain_postgresql__server__config_entry('max_connections').with({
      :value  => '150',
    })
  end

  it do
    should contain_ovirt__engine__db('engine').with({
      :user     => 'engine',
      :password => 'engine'
    })
  end

  it { should_not contain_ovirt__engine__db('ovirt_engine_reports') }
  it { should_not contain_ovirt__engine__db('ovirt_engine_history') }

  context 'when enable_reports => true' do
    let(:params) {{ :enable_reports => true }}

    it do
      should contain_ovirt__engine__db('ovirt_engine_reports').with({
        :user     => 'ovirt_engine_reports',
        :password => 'ovirt_engine_reports'
      })
    end

    it do
      should contain_ovirt__engine__db('ovirt_engine_history').with({
        :user     => 'ovirt_engine_history',
        :password => 'ovirt_engine_history'
      })
    end
  end
end
