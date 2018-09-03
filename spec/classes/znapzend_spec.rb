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

          #it { is_expected.to contain_service('znapzend').with(
          #  'ensure'     => 'running',
          #  'enable'     => 'true',
          #  'hasstatus'  => 'true',
          #  'hasrestart' => 'true',
          #) }
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
