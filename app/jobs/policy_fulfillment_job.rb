class PolicyFulfillmentJob < ApplicationJob
  queue_as :default

  retry_on InsursClient::ApiError, wait: :polynomially_longer, attempts: 5
  retry_on Faraday::TimeoutError, Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: 5

  def perform(policy)
    policy.fulfill!
  end
end
