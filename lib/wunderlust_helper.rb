module WunderlustHelper

  def add_task(title)

    HTTParty.post('https://a.wunderlist.com/api/v1/tasks', 
      headers: {
          'X-Client-ID' => Rails.application.secrets.slack_client_id,
          'X-Access-Token' => Rails.application.secrets.slack_access_token,
          'Content-Type' => 'application/json'
        },
      body: { 
        title: title,
        completed: false,
        list_id: 215891132
      }.to_json,
    )
  end

  def needs_design?(payload)

    @array_of_issue_labels = []
    @array_of_issue_labels << payload[:issue][:labels].map {|l| l.to_hash.values.to_a }
    @array_of_issue_labels.each do |labels|
      labels.flatten!
      if labels.include?("needs: design")
        return true
      end
      return false
    end
  end
end