# app/controllers/github_webhooks_controller.rb
class GithubWebhooksController < ActionController::Base
  include GithubWebhook::Processor

  def push(payload)
    # TODO: handle push webhook
  end

  def issues(payload)
  end

  def webhook_secret(payload)
    Rails.application.secrets.github_webhook_secret
  end
end