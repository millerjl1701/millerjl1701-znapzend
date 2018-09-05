require 'spec_helper_acceptance'

describe 'znapzend class' do
  context 'default parameters' do
    # znapzend service is disabled and stopped since successful running requires
    #   active zfs modules and file systems which is beyond scope of
    #   current testing regimen.
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'znapzend':
        service_enable => false,
        service_ensure => 'stopped',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe yumrepo('epel') do
      it { should exist }
      it { should be_enabled }
    end

    describe package('gcc') do
      it { should be_installed }
    end

    describe package('gcc-c++') do
      it { should be_installed }
    end

    describe package('mbuffer') do
      it { should be_installed }
    end

    describe package('perl-core') do
      it { should be_installed }
    end

    describe file('/etc/default/znapzend') do
      it { should exist }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
      it { should contain 'ZNAPZENDOPTIONS=""' }
    end

    if (fact'osfamily') == 'RedHat' && fact('operatingsystemmajrelease') == '6'
      describe file('/etc/init.d/znapzend') do
        it { should exist }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 755 }
        it { should contain 'daemon --check znapzend /usr/local/bin/znapzend --daemonize $ZNAPZENDOPTIONS' }
      end
    end

    if (fact'osfamily') == 'RedHat' && fact('operatingsystemmajrelease') == '7'
      describe file('/etc/systemd/system/znapzend.service') do
        it { should exist }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        it { should contain 'After=zfs-import-cache.service' }
        it { should contain 'After=zfs-import-scan.service' }
      end
    end

    describe file('/opt/znapzend-0.19.1/bin/znapzend') do
      it { should be_file }
    end

    describe file('/usr/local/bin/znapzend') do
      it { should be_symlink }
    end

    describe file('/usr/local/bin/znapzendzetup') do
      it { should be_symlink }
    end

    describe file('/usr/local/bin/znapzendztatz') do
      it { should be_symlink }
    end

    describe file('/usr/local/src/znapzend-0.19.1') do
      it { should be_directory }
    end

    describe file('/usr/local/src/znapzend-0.19.1/config.status') do
      it { should be_file }
    end

    describe service('znapzend') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end
end
