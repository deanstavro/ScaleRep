  OmniAuth.config.logger = Rails.logger

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :salesforce, '3MVG9uudbyLbNPZNvQPporYkpin6e6cLBwsTOMkkz9cjXFz1KMIrpBmn_ywRPXLswDrA8HpNMf8IOhvlUYk6A', '3691801122754282615'

  end