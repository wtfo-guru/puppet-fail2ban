# frozen_string_literal: true

require 'spec_helper'

describe 'fail2ban' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} with default params" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('Fail2ban::Config') }
      it { is_expected.to contain_class('Fail2ban::Install') }
      it { is_expected.to contain_class('Fail2ban::Service') }
      it { is_expected.to contain_file('/etc/fail2ban/jail.d/00-defaults-puppet.conf').with_ensure('file') }
      it { is_expected.to contain_file('/etc/fail2ban/jail.d/sshd.conf').with_ensure('file') }
      it { is_expected.to contain_file('/etc/fail2ban/jail.d').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/fail2ban/filter.d').with_ensure('directory') }
      it { is_expected.to contain_fail2ban__jail('sshd') }
      it { is_expected.to contain_package('fail2ban') }

      case os_facts[:osfamily]
      when 'RedHat'
        it { is_expected.to contain_package('fail2ban-systemd') }
        if os_facts[:operatingsystem] != 'OracleLinux'
          it { is_expected.to contain_package('epel-release') }
        else
          it { is_expected.not_to contain_package('epel-release') }
        end
      end
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} with defaults + service_name '' " do
      let(:facts) { os_facts }
      let(:params) do
        {
          'service_name' => '',
          'dbpurgeage' => 648_000,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_class('Fail2ban::Config') }
      it { is_expected.to contain_class('Fail2ban::Install') }
      it { is_expected.to contain_class('Fail2ban::Service') }
      it { is_expected.to contain_file('/etc/fail2ban/jail.d/00-defaults-puppet.conf').with_ensure('file') }
      it { is_expected.to contain_file('/etc/fail2ban/jail.d/sshd.conf').with_ensure('file') }
      it { is_expected.to contain_file('/etc/fail2ban/jail.d').with_ensure('directory') }
      it { is_expected.to contain_file('/etc/fail2ban/filter.d').with_ensure('directory') }
      it { is_expected.to contain_package('fail2ban') }
      it { is_expected.not_to contain_service('fail2ban') }
      it { is_expected.to contain_fail2ban__jail('sshd') }
      it { is_expected.to contain_ini_setting('fail2ban-local-dbpurgeage') }
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} with defaults + filter" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'filters' => {
            'apache-access-wtfo' => {
              'ensure' => 'present',
              'ibefore' => ['apache-common.conf'],
              'failregex' => [
                '^<HOST> - - \[.*\] "[A-Z]* .*(?i)fckeditor.*" 404',
                '^<HOST> - - \[.*\] "[A-Z]* .*(?i)phpmyadmin.*" 404',
              ],
            },
          },
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('/etc/fail2ban/filter.d/apache-access-wtfo.local') }
      it { is_expected.to contain_fail2ban__filter('apache-access-wtfo') }
    end
  end
end
