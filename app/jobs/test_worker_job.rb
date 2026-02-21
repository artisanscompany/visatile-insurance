class TestWorkerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "========================================="
    Rails.logger.info "TestWorkerJob starting..."
    Rails.logger.info "Arguments: #{args.inspect}"
    Rails.logger.info "Time: #{Time.current}"
    Rails.logger.info "========================================="

    # Simulate some work
    sleep 5

    Rails.logger.info "========================================="
    Rails.logger.info "TestWorkerJob completed!"
    Rails.logger.info "Time: #{Time.current}"
    Rails.logger.info "========================================="
  end
end
