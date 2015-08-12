require 'puppet'
require 'puppet/type/heat_config'

describe 'Puppet::Type.type(:heat_config)' do
  before :each do
    @heat_config = Puppet::Type.type(:heat_config).new(:name => 'DEFAULT/foo', :value => 'bar')
  end


  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    package = Puppet::Type.type(:package).new(:name => 'heat-common')
    catalog.add_resource package, @heat_config
    dependency = @heat_config.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@heat_config)
    expect(dependency[0].source).to eq(package)
  end

end
