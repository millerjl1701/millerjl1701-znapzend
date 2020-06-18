require 'spec_helper'

describe 'znapzend::imports' do
  context "supported operating systems" do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context  "with custom plans param" do
          let :params do
            {
              plans: {
                'tank/home' => {
                  'options' => {
                    'enabled'       => 'on',
                    'src'           => 'tank/home',
                    'src_plan'      => '7d=>1h,30d=>4h,90d=>1d',
                    'dst_0'         => 'backup/home',
                    'dst_0_plan'    => '7d=>1h,30d=>4h,90d=>1d,1y=>1w,10y=>1month',
                    'mbuffer'       => 'off',
                    'mbuffer_size'  => '1G',
                    'post_znap_cmd' => 'off',
                    'pre_znap_cmd'  => 'off',
                    'recursive'     => 'off',
                    'tsformat'      => '%Y-%m-%d-%H%M%S',
                  },
                }, 
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('znapzend') }
          
          it { is_expected.to contain_znapzend__import('tank/home') }

          it { is_expected.to contain_file('/etc/znapzend/configs/tank_home.conf').with(
            'ensure'  => 'present',
            'mode'    => '0644',
            'owner'   => 'root',
            'group'   => 'root',
            'require' => 'File[/etc/znapzend/configs]',
          ) }
          it { is_expected.to contain_exec('znapzend_import_tank_home').with(
            'command'     => 'cat /etc/znapzend/configs/tank_home.conf | znapzendzetup import --write tank/home',
            'subscribe'   => 'File[/etc/znapzend/configs/tank_home.conf]',
            'refreshonly' => 'true',
            'onlyif'      => 'test -e /tank/home',
            'notify'      => 'Service[znapzend]',
          ) }

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
