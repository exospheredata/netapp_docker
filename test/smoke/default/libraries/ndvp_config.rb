require 'json'

# Custom resource based on the InSpec resource DSL

class NdvpConfigDefaults < Inspec.resource(1)
  name 'ndvp_config_defaults'

  desc "
    NetApp Docker Volume Plug-in Configuration validation for defaults
  "

  example "
    describe ndvp_config_defaults('/etc/netappdvp/config.json') do
      its('size') { should eq('20g') }
      its('exportPolicy') { should eq('default') }
    end
  "

  def initialize(config)
    return skip_resource 'The \'ndvp_config\' resource is not supported on your OS.' if inspec.os.windows?
    @params = {}
    @path = config
    @file = inspec.file(@path)
    return skip_resource "Can't find file \"#{@path}\"" unless @file.file?

    # Protect from invalid YAML content
    begin
      @params = JSON.load(@file.content)
      # Add two extra matchers
      @params['file_size'] = @file.size
      @params['file_path'] = @path
      @defaults = @params['defaults'] || {}
    rescue StandardError
      return skip_resource "#{@file}: #{$ERROR_INFO}"
    end
  end

  def method_missing(name)
    @defaults[name.to_s]
  end
end
class NdvpConfig < Inspec.resource(1)
  name 'ndvp_config'

  desc "
    NetApp Docker Volume Plug-in Configuration validation
  "

  example "
    describe ndvp_config('/etc/netappdvp/config.json') do
      its('version') { should eq('1') }
      its('storage_driver') { should eq('ontap-nas') }
    end
  "

  # Load the configuration file on initialization
  def initialize(config)
    return skip_resource 'The \'ndvp_config\' resource is not supported on your OS.' if inspec.os.windows?
    @params = {}
    @path = config
    @file = inspec.file(@path)
    return skip_resource "Can't find file \"#{@path}\"" unless @file.file?

    # Protect from invalid YAML content
    begin
      @params = JSON.load(@file.content)
      # Add two extra matchers
      @params['file_size'] = @file.size
      @params['file_path'] = @path
      @defaults = get_defaults
    rescue StandardError
      return skip_resource "#{@file}: #{$ERROR_INFO}"
    end
  end

  # Example method called by 'it { should exist }'
  # Returns true or false from the 'File.exists?' method
  def exists?
    File.exist?(@path)
  end

  def defaults
    return @params['defaults'] if @params.key?('defaults')
    {}
  end

  # Expose all parameters
  def method_missing(name)
    @params[name.to_s]
  end
end
