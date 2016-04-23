require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "f18b005c5fdd7494d707a6c661e245d4265e132d2d72e178fefb65ab0a8cb7ff"

  url_format "/media/:job/:name"

  # if Rails.env.development? || Rails.env.test?
    # datastore :file,
    #         root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    #         server_root: Rails.root.join('public')

  # else
    datastore :s3,
      region: 'ap-southeast-2',
      bucket_name: 'personalmasterclass-dev',
      access_key_id: 'AKIAJ4YR5WINZR5IMHCA',
      secret_access_key: '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',
      url_scheme: 'https'
  # end

  fetch_file_whitelist [/public/]
end



# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
