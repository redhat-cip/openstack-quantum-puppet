require 'spec_helper'

describe 'quantum::server' do

  let :params do
    {
      :auth_password => 'passw0rd',
      :auth_user     => 'quantum',
    }
  end

  shared_examples_for 'a quantum server' do
    it { should include_class('quantum::params') }
    it 'configures quantum.conf' do
      should contain_quantum_config('keystone_authtoken/admin_user').with(
        :value => params[:auth_user]
      )
      should contain_quantum_config('keystone_authtoken/auth_admin_prefix').with(
        :ensure => 'absent'
      )
    end
    it 'configures quantum-api.conf' do
      should contain_quantum_api_config('filter:authtoken/admin_user').with(
        :value => params[:auth_user]
      )
      should contain_quantum_api_config('filter:authtoken/auth_admin_prefix').with(
        :ensure => 'absent'
      )
    end
  end

  shared_examples_for 'a quantum server with auth_admin_prefix set' do
    before do
      params.merge({
        :auth_admin_prefix => '/keystone/admin',
      })
    end
    it do
      should contain_quantum_config('keystone_authtoken/auth_admin_prefix').with(
        :value => params[:auth_admin_prefix]
      )
      should contain_quantum_api_config('filter:authtoken/auth_admin_prefix').with(
        :value => params[:auth_admin_prefix]
      )
    end
  end

  shared_examples_for 'a quantum server with some incorrect auth_admin_prefix set' do
    [ '/keystone/', 'keystone/', 'keystone' ].each do |auth_admin_prefix|
      before do
        params.merge({
          :auth_admin_prefix => auth_admin_prefix,
        })
      end
      it do
        expect {
          should contain_quantum_api_config('filter:authtoken/auth_admin_prefix')
        }.to raise_error(Puppet::Error, /validate_re\(\): "#{auth_admin_prefix}" does not match/)
      end
    end
  end

  shared_examples_for 'a quantum server with broken authentication' do
    before do
      params.delete(:auth_password)
    end
    it do
      expect {
        should contain_quantum_api_config('filter:authtoken/admin_user').with(
          :value => params[:auth_user]
        )
      }.to raise_error(Puppet::Error, /auth_password must be set/)
    end
  end


  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'a quantum server'
    it_configures 'a quantum server with broken authentication'
    it_configures 'a quantum server with auth_admin_prefix set'
    it_configures 'a quantum server with some incorrect auth_admin_prefix set'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'a quantum server'
    it_configures 'a quantum server with broken authentication'
    it_configures 'a quantum server with auth_admin_prefix set'
    it_configures 'a quantum server with some incorrect auth_admin_prefix set'
  end
end
