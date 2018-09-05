require 'spec_helper'

describe 'znapzend' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "znapzend class without any parameters changed from defaults" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('znapzend::repos') }
          it { is_expected.to contain_class('znapzend::prereqs') }
          it { is_expected.to contain_class('znapzend::install') }
          it { is_expected.to contain_class('znapzend::config') }
          it { is_expected.to contain_class('znapzend::service') }
          it { is_expected.to contain_class('znapzend::repos').that_comes_before('Class[znapzend::prereqs]') }
          it { is_expected.to contain_class('znapzend::prereqs').that_comes_before('Class[znapzend::install]') }
          it { is_expected.to contain_class('znapzend::install').that_comes_before('Class[znapzend::config]') }
          it { is_expected.to contain_class('znapzend::service').that_subscribes_to('Class[znapzend::config]') }

          it { is_expected.to contain_class('epel') }

          it { is_expected.to contain_package('gcc').with_ensure('present') }
          it { is_expected.to contain_package('gcc-c++').with_ensure('present') }
          it { is_expected.to contain_package('mbuffer').with_ensure('present') }
          it { is_expected.to contain_package('perl-core').with_ensure('present') }

          it { is_expected.to contain_file('/usr/local/src').with_ensure('directory') }
          it { is_expected.to contain_archive('znapzend-0.19.1.tar.gz').with(
            'path'         => '/tmp/znapzend-0.19.1.tar.gz',
            'provider'     => 'wget',
            'source'       => 'https://github.com/oetiker/znapzend/releases/download/v0.19.1/znapzend-0.19.1.tar.gz',
            'extract'      => 'true',
            'extract_path' => '/usr/local/src',
            'creates'      => '/usr/local/src/znapzend-0.19.1',
            'require'      => 'File[/usr/local/src]',
          ) }
          it { is_expected.to contain_exec('znapzend_source_configure').with(
            'command' => './configure --prefix=/opt/znapzend-0.19.1',
            'cwd'     => '/usr/local/src/znapzend-0.19.1',
            'creates' => '/usr/local/src/znapzend-0.19.1/config.status',
          ) }
          it { is_expected.to contain_exec('znapzend_make_and_install').with(
            'command' => 'make && make install',
            'cwd'     => '/usr/local/src/znapzend-0.19.1',
            'creates' => '/opt/znapzend-0.19.1/bin/znapzend',
          ) }
          it { is_expected.to contain_file('/usr/local/bin/znapzend').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/znapzend',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
          it { is_expected.to contain_file('/usr/local/bin/znapzendzetup').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/znapzendzetup',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
          it { is_expected.to contain_file('/usr/local/bin/znapzendztatz').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/znapzendztatz',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }

          it { is_expected.to contain_file('/etc/default/znapzend').with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          ) }
          it { is_expected.to contain_file('/etc/default/znapzend').with_content(/ZNAPZENDOPTIONS=""/) }

          if facts[:os]['family'] == 'RedHat'
            if facts[:os]['release']['major'] == '6'
              it { is_expected.to_not contain_class('systemd::systemctl::daemon_reload') }
              it { is_expected.to contain_file('/etc/init.d/znapzend').with(
                'ensure' => 'present',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0755',
              ) }
              it { is_expected.to contain_file('/etc/init.d/znapzend').with_content(/daemon --check znapzend \/usr\/local\/bin\/znapzend --daemonize \$ZNAPZENDOPTIONS/) }
              it { is_expected.to contain_exec('znapzend_add_sysv_service').with(
                'command'     => '/sbin/chkconfig --add znapzend',
                'refreshonly' => 'true',
                'unless'      => '/bin/ls /etc/rc* | /bin/grep znapzend',
              ) }
            end
            if facts[:os]['release']['major'] == '7'
              it { is_expected.to contain_class('systemd::systemctl::daemon_reload') }
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').with(
                'ensure'  => 'present',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0644',
                'require' => 'File[/etc/default/znapzend]',
              ) }
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').with_content(/After=zfs-import-cache.service/) }
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').with_content(/After=zfs-import-scan.service/) }
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').with_content(/ExecStart=\/usr\/local\/bin\/znapzend \$ZNAPZENDOPTIONS/) }
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').that_notifies('Class[systemd::systemctl::daemon_reload]') }
            end
          end

          it { is_expected.to contain_service('znapzend').with(
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasstatus'  => 'true',
            'hasrestart' => 'true',
          ) }
        end

        context "znapzend class with gcc_packages set to [ foo, bar]" do
          let(:params){
            {
              :gcc_packages => [ 'foo', 'bar', ],
            }
          }

          it { is_expected.to contain_package('foo') }
          it { is_expected.to contain_package('bar') }
        end

        context "znapzend class with manage_epel set to false" do
          let(:params){
            {
              :manage_epel => false,
            }
          }

          it { is_expected.to_not contain_class('epel') }
        end

        context "znapzend class with manage_gcc set to false" do
          let(:params){
            {
              :manage_gcc => false,
            }
          }

          it { is_expected.to_not contain_package('gcc') }
        end

        context "znapzend class with manage_mbuffer set to false" do
          let(:params){
            {
              :manage_mbuffer => false,
            }
          }

          it { is_expected.to_not contain_package('mbuffer') }
        end

        context "znapzend class with manage_perl set to false" do
          let(:params){
            {
              :manage_perl => false,
            }
          }

          it { is_expected.to_not contain_package('perl-core') }
        end

        context "znapzend class with manage_prereqs set to false" do
          let(:params){
            {
              :manage_prereqs => false,
            }
          }

          it { is_expected.to_not contain_package('gcc') }
          it { is_expected.to_not contain_package('mbuffer') }
          it { is_expected.to_not contain_package('perl-core') }
        end

        context "znapzend class with mbuffer_packages set to [ foo, bar]" do
          let(:params){
            {
              :mbuffer_packages => [ 'foo', 'bar', ],
            }
          }

          it { is_expected.to contain_package('foo') }
          it { is_expected.to contain_package('bar') }
        end

        context "znapzend class with perl_packages set to [ foo, bar]" do
          let(:params){
            {
              :perl_packages => [ 'foo', 'bar', ],
            }
          }

          it { is_expected.to contain_package('foo') }
          it { is_expected.to contain_package('bar') }
        end

        context "znapzend class with service_enable set to false" do
          let(:params){
            {
              :service_enable => false,
            }
          }

          it { is_expected.to contain_service('znapzend').with_enable('false') }
        end

        context "znapzend class with service_ensure set to stopped" do
          let(:params){
            {
              :service_ensure => 'stopped',
            }
          }

          it { is_expected.to contain_service('znapzend').with_ensure('stopped') }
        end

        context "znapzend class with service_name set foo" do
          let(:params){
            {
              :service_name => 'foo',
            }
          }

          it { is_expected.to_not contain_service('znapzend') }
          it { is_expected.to contain_service('foo') }
          if facts[:os]['family'] == 'RedHat'
            if facts[:os]['release']['major'] == '6'
              it { is_expected.to contain_file('/etc/init.d/foo').that_notifies('Exec[znapzend_add_sysv_service]') }
              it { is_expected.to contain_exec('znapzend_add_sysv_service').with(
                'command'     => '/sbin/chkconfig --add foo',
                'unless'      => '/bin/ls /etc/rc* | /bin/grep foo',
              ) }
            end
          end
        end

        context 'znapzend class with service_options set to "--daemonize --logto=/var/log/znapzend --pidfile=/var/run/znapzend.pid"' do
          let(:params){
            {
              :service_options => '--daemonize --logto=/var/log/znapzend --pidfile=/var/run/znapzend.pid',
            }
          }

          it { is_expected.to contain_file('/etc/default/znapzend').with_content(/ZNAPZENDOPTIONS="--daemonize --logto=\/var\/log\/znapzend --pidfile=\/var\/run\/znapzend.pid"/) }
        end

        context 'znapzend class with service_systemd_afters set to [ "zfs-mount.service", ]' do
          let(:params){
            {
              :service_systemd_afters => [ 'zfs-mount.service', ],
            }
          }

          if facts[:os]['family'] == 'RedHat'
            if facts[:os]['release']['major'] == '6'
            end
            if facts[:os]['release']['major'] == '7'
              it { is_expected.to_not contain_file('/etc/systemd/system/znapzend.service').with_content(/After=zfs-import-cache.service/) }
              it { is_expected.to_not contain_file('/etc/systemd/system/znapzend.service').with_content(/After=zfs-import-scan.service/) }
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').with_content(/After=zfs-mount.service/) }
            end
          end
        end

        context "znapzend class with znapzend_install_prefix set to /opt/foo" do
          let(:params){
            {
              :znapzend_install_prefix => '/opt/foo',
            }
          }

          it { is_expected.to contain_exec('znapzend_source_configure').with_command('./configure --prefix=/opt/foo') }
          it { is_expected.to contain_exec('znapzend_make_and_install').with_creates('/opt/foo/bin/znapzend') }
          it { is_expected.to contain_file('/usr/local/bin/znapzend').with_target('/opt/foo/bin/znapzend') }
          it { is_expected.to contain_file('/usr/local/bin/znapzendzetup').with_target('/opt/foo/bin/znapzendzetup') }
          it { is_expected.to contain_file('/usr/local/bin/znapzendztatz').with_target('/opt/foo/bin/znapzendztatz') }
        end

        context 'znapzend class with znapzend_installed_binaries set to [ "foo", "bar"' do
          let(:params){
            {
              :znapzend_installed_binaries => [ 'foo', 'bar', ],
            }
          }

          it { is_expected.to_not contain_file('/usr/local/bin/znapzend') }
          it { is_expected.to_not contain_file('/usr/local/bin/znapzendzetup') }
          it { is_expected.to_not contain_file('/usr/local/bin/znapzendztatz') }
          it { is_expected.to contain_file('/usr/local/bin/foo').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/foo',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
          it { is_expected.to contain_file('/usr/local/bin/bar').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/bar',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
        end

        context "znapzend class with znapzend_linkpath set to /foo/bar/bin" do
          let(:params){
            {
              :znapzend_linkpath => '/foo/bar/bin',
            }
          }

          it { is_expected.to_not contain_file('/usr/local/bin/znapzend') }
          it { is_expected.to_not contain_file('/usr/local/bin/znapzendzetup') }
          it { is_expected.to_not contain_file('/usr/local/bin/znapzendzstatz') }
          it { is_expected.to contain_file('/foo/bar/bin/znapzend').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/znapzend',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
          it { is_expected.to contain_file('/foo/bar/bin/znapzendzetup').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/znapzendzetup',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
          it { is_expected.to contain_file('/foo/bar/bin/znapzendztatz').with(
            'ensure'  => 'link',
            'target'  => '/opt/znapzend-0.19.1/bin/znapzendztatz',
            'require' => 'Exec[znapzend_make_and_install]',
          ) }
          if facts[:os]['family'] == 'RedHat'
            if facts[:os]['release']['major'] == '6'
              it { is_expected.to contain_file('/etc/init.d/znapzend').with_content(/daemon --check znapzend \/foo\/bar\/bin\/znapzend --daemonize \$ZNAPZENDOPTIONS/) }
            end
            if facts[:os]['release']['major'] == '7'
              it { is_expected.to contain_file('/etc/systemd/system/znapzend.service').with_content(/ExecStart=\/foo\/bar\/bin\/znapzend \$ZNAPZENDOPTIONS/) }
            end
          end
        end

        context "znapzend class with znapzend_package_extractpath set to /root" do
          let(:params){
            {
              :znapzend_package_extractpath => '/root',
            }
          }

          it { is_expected.to contain_file('/root').with_ensure('directory') }
          it { is_expected.to contain_archive('znapzend-0.19.1.tar.gz').with(
            'extract_path' => '/root',
            'creates'      => '/root/znapzend-0.19.1',
            'require'      => 'File[/root]',
          ) }
          it { is_expected.to contain_exec('znapzend_source_configure').with(
            'cwd'     => '/root/znapzend-0.19.1',
            'creates' => '/root/znapzend-0.19.1/config.status',
            ) }
        end

        context "znapzend class with znapzend_package_url set to http://mirror.example.com/pub/znapzend/znapzend-0.19.1.tar.gz" do
          let(:params){
            {
              :znapzend_package_url => 'http://mirror.example.com/pub/znapzend/znapzend-0.19.1.tar.gz',
            }
          }

          it { is_expected.to contain_archive('znapzend-0.19.1.tar.gz').with_source('http://mirror.example.com/pub/znapzend/znapzend-0.19.1.tar.gz') }
        end

        context "znapzend class with znapzend_package_version set to 0.15.7" do
          let(:params){
            {
              :znapzend_package_version => '0.15.7',
            }
          }

          it { is_expected.to contain_archive('znapzend-0.15.7.tar.gz').with(
            'path'         => '/tmp/znapzend-0.15.7.tar.gz',
            'source'       => 'https://github.com/oetiker/znapzend/releases/download/v0.15.7/znapzend-0.15.7.tar.gz',
            'creates'      => '/usr/local/src/znapzend-0.15.7',
          ) }
          it { is_expected.to contain_exec('znapzend_source_configure').with(
            'cwd'     => '/usr/local/src/znapzend-0.15.7',
            'creates' => '/usr/local/src/znapzend-0.15.7/config.status',
          ) }
          it { is_expected.to contain_exec('znapzend_make_and_install').with(
            'cwd'     => '/usr/local/src/znapzend-0.15.7',
            'creates' => '/opt/znapzend-0.15.7/bin/znapzend',
          ) }
          it { is_expected.to contain_file('/usr/local/bin/znapzend').with_target('/opt/znapzend-0.15.7/bin/znapzend') }
          it { is_expected.to contain_file('/usr/local/bin/znapzendzetup').with_target('/opt/znapzend-0.15.7/bin/znapzendzetup') }
          it { is_expected.to contain_file('/usr/local/bin/znapzendztatz').with_target('/opt/znapzend-0.15.7/bin/znapzendztatz') }

        end

      end
    end
  end

  context 'unsupported operating system' do
    describe 'znapzend class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('znapzend') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
