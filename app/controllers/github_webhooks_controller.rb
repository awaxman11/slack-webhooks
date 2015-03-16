require 'slack-notifier'

# app/controllers/github_webhooks_controller.rb
class GithubWebhooksController < ActionController::Base
  include GithubWebhook::Processor

  def push(payload)
    # TODO: handle push webhook
  end

  def issues(payload)

    # TODO 3/15/15
    # Refactor this action and make code DRY
    if payload[:action] == "labeled"
      if payload[:label][:name] == "needs: design"
        case payload[:repository][:name]
        when "gh-tester"
          icon_url = "http://cl.ly/aEPm/needs-design-tixcast.png"
        when "android-app"
          icon_url = "http://cl.ly/aDvb/needs-design-android.png"
        when "iphone-app"
          icon_url = "http://cl.ly/aDfL/needs-design-iphone.png"
        when "tixcast"
          icon_url = "http://cl.ly/aEPm/needs-design-tixcast.png"
        else
          icon_url = "http://cl.ly/aEkW/slack-logo.png"
        end
        notifier = Slack::Notifier.new Rails.application.secrets.slack_webhook_url
        notifier.username = "needs design"
        notifier.ping "<#{payload[:issue][:html_url]}|#{payload[:repository][:name]} ##{payload[:issue][:number]}: #{payload[:issue][:title]}>" + ((payload[:issue][:body] != "") ? "\n>#{payload[:issue][:body].gsub(/([!])/, '') }\n>" : ""), icon_url: icon_url
      elsif payload[:label][:name] == "needs: feedback"
        case payload[:repository][:name]
        when "gh-tester"
          icon_url = "http://cl.ly/aEIO/needs-feedback-tixcast.png"
        when "android-app"
          icon_url = "http://cl.ly/aEWB/needs-feedback-android.png"
        when "iphone-app"
          icon_url = "http://cl.ly/aE2M/needs-feedback-iphone.png"
        when "tixcast"
          icon_url = "http://cl.ly/aEIO/needs-feedback-tixcast.png"
        else
          icon_url = "http://cl.ly/aEkW/slack-logo.png"
        end
        notifier = Slack::Notifier.new Rails.application.secrets.slack_webhook_url
        notifier.username = "needs feedback"
        notifier.ping "<#{payload[:issue][:html_url]}|#{payload[:repository][:name]} ##{payload[:issue][:number]}: #{payload[:issue][:title]}>" + ((payload[:issue][:body] != "") ? "\n>#{payload[:issue][:body].gsub(/([!])/, '') }\n>" : ""), icon_url: icon_url
      end
    end
  end

  def webhook_secret(payload)
    Rails.application.secrets.github_webhook_secret
  end
end