require 'spec_helper'

describe 'znapzend::imports' do
  context "supported operating systems" do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context  "params via hiera" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('znapzend') }

          it { is_expected.to contain_file('/etc/znapzend/dpool01_test1') }
          it { is_expected.to contain_file('/etc/znapzend/dpool02_test2') }

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
