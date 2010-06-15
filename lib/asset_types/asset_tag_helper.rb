module ActionView::Helpers::AssetTagHelper
  def javascript_path_with_asset_type(source, options={})
    with_asset_type options.delete(:asset_type) do
      javascript_path_without_asset_type(source)
    end
  end
  alias_method_chain :javascript_path, :asset_type
  alias_method :path_to_javascript, :javascript_path

  def javascript_include_tag_with_asset_type(*sources)
    with_asset_type(sources.last.is_a?(Hash) ? sources.last.delete(:asset_type) : nil ) do
      javascript_include_tag_without_asset_type(*sources)
    end
  end
  alias_method_chain(:javascript_include_tag, :asset_type)

  def stylesheet_path_with_asset_type(source, options={})
    with_asset_type options.delete(:asset_type) do
      stylesheet_path_without_asset_type(source)
    end
  end
  alias_method_chain :stylesheet_path, :asset_type
  alias_method :path_to_stylesheet, :stylesheet_path

  def stylesheet_link_tag_with_asset_type(*sources)
    with_asset_type(sources.last.is_a?(Hash) ? sources.last.delete(:asset_type) : nil ) do
      stylesheet_link_tag_without_asset_type(*sources)
    end
  end
  alias_method_chain :stylesheet_link_tag, :asset_type

  def image_path_with_asset_type(source, options={})
    with_asset_type options.delete(:asset_type) do
      image_path_without_asset_type(source)
    end
  end
  alias_method_chain :image_path, :asset_type
  alias_method :path_to_image, :image_path

  def image_tag_with_asset_type(source, options={})
    with_asset_type(options.delete(:asset_type)) do
      image_tag_without_asset_type(source, options)
    end
  end
  alias_method_chain :image_tag, :asset_type

private
  # It sets the @__asset_type variable because we cant pass it down
  # the call chain to compute_asset_host and resets to nil on the way
  # returning.
  def with_asset_type(asset_type) 
    # Because of nesting calls between *_tags -> *_paths in which
    # case @__asset_type may already have a value
    @__asset_type = asset_type || @__asset_type
    retval = yield
    @__asset_type = nil

    retval
  end

  # Pick an asset host for this source. Returns +nil+ if no host is set,
  # the host if no wildcard is set, the host interpolated with the
  # numbers 0-3 if it contains <tt>%d</tt> (the number is the source hash mod 4),
  # or the value returned from invoking the proc if it's a proc or the value from
  # invoking call if it's an object responding to call.
  def compute_asset_host(source)
    asset_type = @__asset_type || 'default'

    if host = lookup_asset_host(asset_type)
      if host.is_a?(Proc) || host.respond_to?(:call)
        case host.is_a?(Proc) ? host.arity : host.method(:call).arity
        when 2
          request = @controller.respond_to?(:request) && @controller.request
          host.call(source, request)
        else
          host.call(source)
        end
      else
        # Our friends at ICDS are slow.  We did not request the asset hosts with a 0 based-index.
        # (host =~ /%d/) ? host % (source.hash % 4) : host
        (host =~ /%d/) ? host % (source.hash % 4 + 1) : host
      end
    end
  end

  def lookup_asset_host(asset_type='default')
    asset_type ||= 'default'

    ActionController::Base.asset_hosts[asset_type] || ActionController::Base.asset_host
  end
end
