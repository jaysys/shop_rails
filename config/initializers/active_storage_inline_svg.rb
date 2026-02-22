# Allow SVG images to render inline from Active Storage.
# Default Rails settings often force SVG to binary download for safety.
Rails.application.config.after_initialize do
  config = Rails.application.config.active_storage

  if config.content_types_to_serve_as_binary.include?("image/svg+xml")
    config.content_types_to_serve_as_binary = config.content_types_to_serve_as_binary - ["image/svg+xml"]
  end

  unless config.content_types_allowed_inline.include?("image/svg+xml")
    config.content_types_allowed_inline << "image/svg+xml"
  end
end
