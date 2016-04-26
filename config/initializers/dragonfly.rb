require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret 'FCGAPAdIigA5qcDvP955fGdJVW4a5kFy27Qr62NCe2Hl34Bfa89NI13eDYND3FrL'

  url_format "/media/:job/:name"

  if Rails.env.development? || Rails.env.test?
    datastore :file,
            root_path: Rails.root.join('public/system/dragonfly', Rails.env),
            server_root: Rails.root.join('public')

  else
    datastore :s3,
      region: 'ap-southeast-2',
      bucket_name: 'personalmasterclass-dev',
      access_key_id: Figaro.env.s3_key,
      secret_access_key: Figaro.env.s3_secret,
      url_scheme: 'https'
  end

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
