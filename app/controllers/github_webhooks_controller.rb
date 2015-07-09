require 'slack-notifier'
require 'octokit'

# app/controllers/github_webhooks_controller.rb
class GithubWebhooksController < ActionController::Base
  include GithubWebhook::Processor

  def push(payload)
    # TODO: handle push webhook
  end
  def component_team_mappings
    {
      'CHECKOUT-API' => 'team: 1',
      'BUNYAN' => 'team: 1',
      'LEDGERMAN' => 'team: 1',
      'LISTINGFEED' => 'team: 2',
      'UBERSEAT' => 'team: 2',
      'MERCURY' => 'team: 2',
      'ACCOUNT' => 'team: 3',
      'BUNYAN-ADMIN' => 'team: 3'
    }
  end
  def auto_add_team_label(payload)
    component_team_mappings = this.component_team_mappings
    component_team_mappings.each { |component, team|
      if payload[:issue][:title].include? component
        client.add_labels_to_an_issue(payload[:repository][:full_name], payload[:issue][:number], team)
      end
    }
  end
  def issues(payload)

    client = Octokit::Client.new \
      :login    => Rails.application.secrets.github_login,
      :password => Rails.application.secrets.github_pass

    if payload[:action] == "opened" 
      issue_number = payload[:issue][:number]
      repo = payload[:repository][:name]
      full_repo_name = payload[:repository][:full_name]
      if repo == "tixcast"
        client.add_labels_to_an_issue(full_repo_name, issue_number, ['status: needs triage'])
        auto_add_team_label(payload)
      end
    end

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