#
# Cookbook Name:: jenkins
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'jenkins::nginxssl' do
    context 'When jenkins is installed, on RHEL/CentOS' do
        let(:chef_run) do
            ChefSpec::SoloRunner.new do |node|
                node.automatic['fqdn'] = 'unit.testing.stub'
            end.converge(described_recipe)
        end

        before(:each) do
            stub_command('[[ -h /usr/java/jdk1.8.0_71/jre/lib/security/cacerts ]]').and_return(false)
            stub_command('update-ca-trust check | grep p11-kit-trust.so').and_return(false)
            allow(Chef::EncryptedDataBagItem).to receive(:load).with('internal-ca', 'unit.testing.stub').and_return(
                'certificate' => 'unit_test_certificate_stub',
                'privateKey' => 'unit_test_key_stub')
        end

        it 'installs thes package nginx' do
            expect(chef_run).to install_yum_package('nginx')
        end

        it 'executes both start and enable actions for nginx' do
            expect(chef_run).to enable_service('nginx')
        end

        it 'deletes a file default.conf' do
            expect(chef_run).to delete_file('/etc/nginx/conf.d/default.conf')
        end

        it 'creates a directory certs' do
            expect(chef_run).to create_directory('/etc/nginx/certs')
        end

        it 'writes ssl certificate and key' do
            cert_template = chef_run.template('/etc/nginx/certs/ssl.cert')
            expect(chef_run).to create_template('/etc/nginx/certs/ssl.cert')
                .with(
                    source: 'ssl.cert.erb',
                    mode: '0440',
                    owner: 'root',
                    group: 'root'
                )
            expect(cert_template).to notify('service[nginx]').to(:restart).delayed

            key_template = chef_run.template('/etc/nginx/certs/ssl.key')
            expect(chef_run).to create_template('/etc/nginx/certs/ssl.key')
                .with(
                    source: 'ssl.key.erb',
                    mode: '0440',
                    owner: 'root',
                    group: 'root'
                )
            expect(key_template).to notify('service[nginx]').to(:restart).delayed
        end

        it 'creates jkvhost.conf' do
            expect(chef_run).to create_template('/etc/nginx/conf.d/jkvhost.conf')
                .with(
                    source: 'jkvhost.conf.erb',
                    mode: '0644',
                    owner: 'root',
                    group: 'root'
                )
        end
    end
end
