require 'net/http'
require 'nokogiri'

module OpenWeatherApi
  extend self

  TIME_PART_PER_DAY = 8
  OPEN_WEATHER_PATH = "http://api.openweathermap.org/data/2.5"

  def get_daily_forecast()
    params = { q: 'London', mode: 'xml', units: 'metric',
               APPID: Rails.application.credentials.open_weather_app_id }

    url = URI.parse("#{OPEN_WEATHER_PATH}/forecast?#{params.to_query}")
    request = Net::HTTP::Get.new(url.to_s)
    response = Net::HTTP.start(url.host, url.port) do |http|
      http.request(request)
    end

    parse_xml(response.body)
  end

  private

  # convert required fields from xml to json array
  def parse_xml(body)
    xml = Nokogiri::XML(body)
    json = []

    times = xml.xpath("//forecast/time")[0..TIME_PART_PER_DAY]
    times.each_with_index do |t, index|
      json[index] = {}
      json[index][:timeFrom]      = t.at_xpath('@from').to_s
      json[index][:timeTo]        = t.at_xpath('@to').to_s
      json[index][:temperature]   = t.at_xpath('temperature/@value').to_s
      json[index][:pressure]      = t.at_xpath('pressure/@value').to_s
      json[index][:humidity]      = t.at_xpath('humidity/@value').to_s
      json[index][:windDirection] = t.at_xpath('windDirection/@name').to_s
      json[index][:windSpeed]     = t.at_xpath('windSpeed/@mps').to_s
    end
    json
  end
end
