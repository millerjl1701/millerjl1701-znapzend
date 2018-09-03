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

          it { is_expected.to contain_class('znapzend::install') }
          it { is_expected.to contain_class('znapzend::config') }
          it { is_expected.to contain_class('znapzend::service') }
          it { is_expected.to contain_class('znapzend::install').that_comes_before('Class[znapzend::config]') }
          it { is_expected.to contain_class('znapzend::service').that_subscribes_to('Class[znapzend::config]') }

          it { is_expected.to contain_package('znapzend').with_ensure('present') }

          it { is_expected.to contain_service('znapzend').with(
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasstatus'  => 'true',
            'hasrestart' => 'true',
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
