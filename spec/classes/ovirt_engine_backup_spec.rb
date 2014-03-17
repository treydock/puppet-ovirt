require 'spec_helper'

describe 'ovirt::engine::backup' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('ovirt::engine::backup') }
  it { should contain_class('ovirt::engine') }

  it do
    should contain_cron('engine-backup').with({
      'ensure'  => 'present',
      'command' => '/usr/local/sbin/enginebackup.sh',
      'user'    => 'root',
      'hour'    => '23',
      'minute'  => '5',
      'require' => 'File[enginebackup.sh]',
    })
  end

  it do
    should contain_file('enginebackup.sh').with({
      'ensure'  => 'present',
      'path'    => '/usr/local/sbin/enginebackup.sh',
      'mode'    => '0700',
      'owner'   => 'root',
      'group'   => 'root',
      'require' => 'Package[ovirt-engine]',
    })
  end

  it do
    content = catalogue.resource('file', 'enginebackup.sh').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'DIR=/tmp/engine-backup',
      'ROTATE=29',
      'PREFIX=engine_backup',
      'PATH=/usr/bin:/usr/sbin:/bin:/sbin',
      'set -o pipefail',
      'cleanup()',
      '{',
      '    find "${DIR}/" -maxdepth 1 -type f -name "${PREFIX}*.tar.bz2" -mtime +${ROTATE} -print0 | xargs -0 -r rm -f',
      '}',
      'cleanup',
      'engine-backup --mode=backup --scope=all --file=${DIR}/${PREFIX}_`date +%Y%m%d-%H%M%S`.tar.bz2 --log=${DIR}/${PREFIX}.log',
    ]
  end

  it do
    should contain_file('enginebackupdir').with({
      'ensure'  => 'directory',
      'path'    => '/tmp/engine-backup',
      'mode'    => '0700',
      'owner'   => 'root',
      'group'   => 'root',
    })
  end

  context 'when delete_before_backup => false' do
    let(:params) {{ :delete_before_backup => false }}
    it do
      content = catalogue.resource('file', 'enginebackup.sh').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'DIR=/tmp/engine-backup',
        'ROTATE=29',
        'PREFIX=engine_backup',
        'PATH=/usr/bin:/usr/sbin:/bin:/sbin',
        'set -o pipefail',
        'cleanup()',
        '{',
        '    find "${DIR}/" -maxdepth 1 -type f -name "${PREFIX}*.tar.bz2" -mtime +${ROTATE} -print0 | xargs -0 -r rm -f',
        '}',
        'engine-backup --mode=backup --scope=all --file=${DIR}/${PREFIX}_`date +%Y%m%d-%H%M%S`.tar.bz2 --log=${DIR}/${PREFIX}.log',
        'if [ $? -eq 0 ] ; then',
        '    cleanup',
        'fi',
      ]
    end
  end

  context 'when backup_dir => "/backups"' do
    let(:params) {{ :backup_dir => "/backups" }}

    it { should contain_file('enginebackupdir').with_path('/backups') }

    it do
      verify_contents(catalogue, 'enginebackup.sh', [
        'DIR=/backups',
      ])
    end
  end

  # Test boolean validation
  [
    'delete_before_backup',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('ovirt::engine::backup') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end
end
