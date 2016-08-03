#
# Cookbook Name:: jenkins
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'jenkins::default' do
    context 'When jenkins is installed, on RHEL/CentOS' do
        let(:chef_run) do
            ChefSpec::SoloRunner.new do |node|
                
            end.converge(described_recipe)
        end

        it 'installs the package jenkins' do
            expect(chef_run).to install_yum_package('jenkins')
        end

        it 'installs the package docker-engine' do
            expect(chef_run).to install_yum_package('docker-engine')
        end

        it 'enables jenkins' do
            expect(chef_run).to enable_service('jenkins')
        end

        it 'restarts and enables docker-engine' do
            expect(chef_run).to enable_service('docker')
            expect(chef_run).to restart_service('docker')
        end

        it 'creates a directory plugins' do
            expect(chef_run).to create_directory('/var/lib/jenkins/plugins')
                .with(
                    owner: 'jenkins',
                    group: 'jenkins',
                    mode: '0755'
                )
        end

        it 'creates the config directory' do
            expect(chef_run).to create_directory('/var/lib/jenkins/config')
                .with(
                    owner: 'jenkins',
                    group: 'jenkins',
                    mode: '0755'
                )
        end

        it 'writes config.xml' do
            template = chef_run.template('/var/lib/jenkins/config/config.xml')
            expect(chef_run).to create_template('/var/lib/jenkins/config/config.xml')
                .with(
                    source: 'config.xml.erb',
                    mode: '0664',
                    owner: 'jenkins',
                    group: 'jenkins'
                )
            expect(template).to notify('service[jenkins]').to(:restart).delayed
        end

        it 'creates the jenkins cli jar' do
            expect(chef_run).to create_cookbook_file('/usr/local/jenkins-cli.jar')
        end

        it 'writes config.xml' do
            template = chef_run.template('/etc/sysconfig/jenkins')
            expect(chef_run).to create_template('/etc/sysconfig/jenkins')
                .with(
                    source: 'jenkins.erb',
                    mode: '0664',
                    owner: 'root',
                    group: 'root'
                )
            expect(template).to notify('service[jenkins]').to(:restart).delayed
        end
    end
end
