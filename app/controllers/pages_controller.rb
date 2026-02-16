class PagesController < ApplicationController
  def index
    render inertia: "Home", props: {
      projects: fetch_projects,
      faqs: fetch_faqs
    }
  end

  private

  def fetch_projects
    uri = URI("https://crewsbase.app/api/crm/rows")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV["CREWSBASE_PROJECTS_API_KEY"]}"

    response = http.request(request)
    data = JSON.parse(response.body)

    field_ids = {
      name: "2af26d57-e596-4753-ac94-aed6205ee423",
      category: "65890191-51a7-45ba-aaa1-e19c8b51cb0b",
      description: "5010ac05-4612-4f54-b41a-8f496ecb6583",
      url: "05afed27-a413-425d-8c19-dc62516a6708",
      image: "bb36ded9-f4c3-4298-8563-6132db814aa6"
    }

    (data["data"] || []).map do |row|
      values = row["values"]
      {
        id: row["id"],
        name: values[field_ids[:name]],
        category: values[field_ids[:category]],
        description: values[field_ids[:description]],
        url: values[field_ids[:url]],
        image: values[field_ids[:image]]
      }
    end
  rescue => e
    Rails.logger.error("Crewsbase projects API error: #{e.message}")
    []
  end

  def fetch_faqs
    uri = URI("https://crewsbase.app/api/crm/rows")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV["CREWSBASE_FAQ_API_KEY"]}"

    response = http.request(request)
    data = JSON.parse(response.body)

    field_ids = {
      question: "6d8af93d-407b-4186-8ed3-2bf2723af0b0",
      answer: "a7ff03cc-1a11-4e88-92b3-27feb4480728"
    }

    (data["data"] || []).map do |row|
      values = row["values"]
      {
        id: row["id"],
        question: values[field_ids[:question]],
        answer: values[field_ids[:answer]]
      }
    end
  rescue => e
    Rails.logger.error("Crewsbase FAQ API error: #{e.message}")
    []
  end
end
