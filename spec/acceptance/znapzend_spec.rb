require 'spec_helper_acceptance'

describe 'znapzend class' do
  context 'default parameters' do
    # znapzend service is disabled and stopped since successful running requires
    #   active zfs modules and file systems which is beyond scope of
    #   current testing regimen.
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      include ::epel
      package { 'kernel-devel':
        ensure  => present,
        require => Class['epel'],
      }
      case $::operatingsystemmajrelease {
        '7': {
          yumrepo { 'zfs':
            ensure   => present,
            enabled  => '1',
            descr    => 'ZFS on Linux for EL 7 - dkms',
            baseurl  => 'http://download.zfsonlinux.org/epel/7/$basearch/',
            gpgcheck => '0',
          }
        }
        '6': {
          yumrepo { 'zfs':
            ensure   => present,
            enabled  => '1',
            descr    => 'ZFS on Linux for EL 6 - dkms',
            baseurl  => 'http://download.zfsonlinux.org/epel/6/$basearch/',
            gpgcheck => '0',
          }
        }
        default: {
          fail("${::operatingsystem} ${::operatingsystemmajrelease} not supported")
        }
      }
      package { 'zfs':
        ensure  => present,
        require => [ Package['kernel-devel'], Yumrepo['zfs'], ],
      }
      file { '/zdisks':
        ensure => directory,
      }
      exec { 'load_kernel_module':
        command => '/sbin/modprobe zfs',
        unless  => '/sbin/lsmod | grep zfs',
        require => Package['zfs'],
      }
      exec { 'create_disks_for_zpools':
        command => 'truncate --size 10G disk1.img disk2.img disk3.img disk4.img',
        cwd     => '/zdisks',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin', ],
        creates => '/zdisks/disk1.img',
        require => [ File['/zdisks'], Exec['load_kernel_module'], ],
      }
      exec { 'create_zpool_tank':
        command => 'zpool create tank /zdisks/disk1.img /zdisks/disk2.img',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin', ],
        creates => '/tank',
        require => [ Package['zfs'], Exec['create_disks_for_zpools'], ],
      }
      exec { 'create_zpool_backup':
        command => 'zpool create backup /zdisks/disk3.img /zdisks/disk4.img',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin', ],
        creates => '/backup',
        require => [ Package['zfs'], Exec['create_disks_for_zpools'], ],
      }
      exec { 'create_zfs_tank_home':
        command => 'zfs create tank/home',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin', ],
        creates => '/tank/home',
        require => Exec['create_zpool_tank'],
      }
      exec { 'create_zfs_backup_home':
        command => 'zfs create backup/home',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin', ],
        creates => '/backup/home',
        require => [ Exec['create_zpool_backup'], Exec['create_zfs_tank_home'], ],
      }
      -> class { 'znapzend': }
      znapzend::import { 'tank/home':
        options => {
          enabled => 'on',
          src => 'tank/home',
          src_plan => '7d=>1h,30d=>4h,90d=>1d',
          dst_0 => 'backup/home',
          dst_0_plan => '7d=>1h,30d=>4h,90d=>1d,1y=>1w,10y=>1month',
          mbuffer => 'off',
          mbuffer_size => '1G',
          post_znap_cmd => 'off',
          pre_znap_cmd => 'off',
          recursive => 'off',
          tsformat => '%Y-%m-%d-%H%M%S',
        },
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

    describe file('/etc/znapzend') do
      it { should be_directory }
    end

    describe file('/etc/znapzend/configs') do
      it { should be_directory }
    end

    describe file('/etc/znapzend/configs/tank_home.conf') do
      it { should exist }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        it { should contain 'src=tank/home' }
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

    describe zfs('tank/home') do
      it { should exist }
      it { should have_property 'org.znapzend:dst_0'         => 'backup/home' }
      it { should have_property 'org.znapzend:dst_0_plan'    => '7days=>1hours,30days=>4hours,90days=>1days,1years=>1weeks,10years=>1months' }
      it { should have_property 'org.znapzend:enabled'       => 'on' }
      it { should have_property 'org.znapzend:mbuffer'       => 'off' }
      it { should have_property 'org.znapzend:mbuffer_size'  => '1G' }
      it { should have_property 'org.znapzend:post_znap_cmd' => 'off' }
      it { should have_property 'org.znapzend:pre_znap_cmd'  => 'off' }
      it { should have_property 'org.znapzend:recursive'     => 'off' }
      it { should have_property 'org.znapzend:src_plan'      => '7days=>1hours,30days=>4hours,90days=>1days' }
      it { should have_property 'org.znapzend:tsformat'      => '%Y-%m-%d-%H%M%S' }
    end

    describe zfs('backup/home') do
      it { should exist }
      it { should have_property 'mountpoint' => '/backup/home', 'compression' => 'off' }
    end

    describe service('znapzend') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
