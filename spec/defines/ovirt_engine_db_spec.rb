require 'spec_helper'

describe 'ovirt::engine::db' do
  include_context :defaults

  let(:facts) { default_facts }

  context 'engine db' do
    let(:title) { 'engine' }
    let(:params) do
      {
        :password => 'engine',
        :user     => 'engine',
      }
    end
    
    it do
      should contain_postgresql__server__pg_hba_rule('allow engine access on 0.0.0.0/0 using md5').with({
        :type         => 'host',
        :database     => 'engine',
        :user         => 'engine',
        :address      => '0.0.0.0/0',
        :auth_method  => 'md5',
        :order        => '010',
      })
    end

    it do
      should contain_postgresql__server__pg_hba_rule('allow engine access on ::0/0 using md5').with({
        :type         => 'host',
        :database     => 'engine',
        :user         => 'engine',
        :address      => '::0/0',
        :auth_method  => 'md5',
        :order        => '011',
      })
    end

    it do
      should contain_postgresql__server__role('engine').with({
        :username => 'engine',
        :before   => 'Postgresql::Server::Database[engine]',
      })
    end

    it do
      should contain_postgresql__server__database('engine').with({
        :encoding => 'UTF8',
        :locale   => 'en_US.UTF-8',
        :template => 'template0',
        :owner    => 'engine',
      })
    end
  end
end
