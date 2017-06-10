if defined?(ChefSpec)
  # DefineMatcher allow us to expose the concept of the method to chef_run during testing.
  ChefSpec.define_matcher(:netapp_docker_ontap_plugin)

  def install_netapp_docker_ontap_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netapp_docker_ontap_plugin, :install, resource_name)
  end

  def config_netapp_docker_ontap_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netapp_docker_ontap_plugin, :config, resource_name)
  end
end
