#!/usr/bin/env bash

wget http://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb 
sudo apt-get update
sudo apt-get install puppet
