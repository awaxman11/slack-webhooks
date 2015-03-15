require 'slack-notifier'

# app/controllers/github_webhooks_controller.rb
class GithubWebhooksController < ActionController::Base
  include GithubWebhook::Processor

  def push(payload)
    # TODO: handle push webhook
  end

  def issues(payload)
    if payload[:action] == "labeled"
      if payload[:label][:name] == "needs: design"
        notifier = Slack::Notifier.new Rails.application.secrets.slack_webhook_url
        notifier.username = "#{payload[:repository][:name]}"
        notifier.ping "<#{payload[:issue][:html_url]}|##{payload[:issue][:number]}: #{payload[:issue][:title]}> needs design" + "\n >#{payload[:issue][:body].gsub(/([!])/, '') }\n>" if payload[:issue][:body] != ""
      end
    end
  end

  def webhook_secret(payload)
    Rails.application.secrets.github_webhook_secret
  end
end