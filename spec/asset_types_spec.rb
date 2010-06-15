require File.dirname(__FILE__) + '/spec_helper'

describe ActionView::Helpers::AssetTagHelper, :type => :helper do
  before(:each) do
    @__previous_asset_host = ActionController::Base.asset_host
    ActionController::Base.asset_host = ""

    @__previous_asset_hosts = ActionController::Base.asset_hosts
    ActionController::Base.asset_hosts = {}
  end

  after(:each) do
    ActionController::Base.asset_host = @__previous_asset_host
    ActionController::Base.asset_hosts = @__previous_asset_hosts
  end

  describe 'with empty asset_host configuration' do
    {'image' => '/images/foo.jpg', 'javascript' => '/javascripts/foo.js', 'stylesheet' => '/stylesheets/foo.css'}.each do |type, path|
      it "does not add anything to #{type} paths" do
        helper.send("#{type}_path", path).should == path
      end
    end
  end

  describe 'with asset_host configuration' do
    before(:each) do
      @asset_host = 'http://asset_host.com'
      ActionController::Base.asset_host = @asset_host
    end

    {'image' => '/images/foo.jpg', 'javascript' => '/javascripts/foo.js', 'stylesheet' => '/stylesheets/foo.css'}.each do |type, path|
      it "adds asset host to #{type} paths" do
        helper.send("#{type}_path", path).should == "#{@asset_host}#{path}"
      end
    end
  end

  describe 'with asset_hosts configuration' do
    before(:each) do
      @asset_hosts = {'default' => 'http://default_host.com', 'alternate' => 'http://alternate_host.com'}
      ActionController::Base.asset_hosts = @asset_hosts
    end

    {'image' => 'jpg', 'javascript' => 'js', 'stylesheet' => 'css'}.each do |type,ext|
      it "adds the default asset host to #{type.pluralize} by default" do
        helper.send("#{type}_path", "/#{type.pluralize}/foo.#{ext}").should == "http://default_host.com/#{type.pluralize}/foo.#{ext}"
      end

      it "adds the default asset host to #{type.pluralize} when explicitly stated" do
        helper.send("#{type}_path", "/#{type.pluralize}/foo.#{ext}", :asset_type => "default").should == "http://default_host.com/#{type.pluralize}/foo.#{ext}"
      end

      it "adds the asset host specified to #{type.pluralize}" do
        helper.send("#{type}_path", "/#{type.pluralize}/foo.#{ext}", :asset_type => "alternate").should == "http://alternate_host.com/#{type.pluralize}/foo.#{ext}"
      end
    end

    it 'creates image tags with the asset type specified' do
      helper.image_tag('foo.jpg', :asset_type => 'alternate').should =~ %r{src=(['"])http://alternate_host.com/images/foo.jpg\1}
    end

    it 'creates javascript tags with the asset type specified' do
      helper.javascript_include_tag('foo.js', :asset_type => 'alternate').should =~ %r{src=(['"])http://alternate_host.com/javascripts/foo.js\1}
    end

    it 'creates stylesheet tags with the asset type specified' do
      helper.stylesheet_link_tag('foo.css', :asset_type => 'alternate').should =~ %r{href=(['"])http://alternate_host.com/stylesheets/foo.css\1}
    end

    it '[BUG] does not reuse the asset_type from the previous call if the previous call was made with a fully qualified url and with an asset_host' do
      helper.image_path('http://yp.com/images/foo.gif', :asset_type => 'alternate')

      helper.image_path('/some_image.gif').should == 'http://default_host.com/some_image.gif'
    end
  end
end
