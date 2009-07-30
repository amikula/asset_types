ActionController::Base.class_eval do
  cattr_accessor :asset_hosts
  self.asset_hosts = {}
end

require 'asset_types/asset_tag_helper'
