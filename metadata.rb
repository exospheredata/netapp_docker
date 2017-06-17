name 'netapp_docker'
maintainer 'Exosphere Data, LLC'
maintainer_email 'chef@exospheredata.com'
license 'all_rights'
description 'Installs/Configures the NetApp Docker Volume Plug-in'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version '0.2.0'
chef_version '>= 12.5' if respond_to?(:chef_version)

%w(debian ubuntu centos redhat amazon).each do |os|
  supports os
end

depends 'docker'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/exospheredata/netapp_docker/issues' if respond_to?(:issues_url)

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/exospheredata/netapp_docker' if respond_to?(:source_url)
