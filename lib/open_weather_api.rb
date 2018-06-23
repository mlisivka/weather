require 'net/http'
require 'nokogiri'
require 'csv'

module OpenWeatherApi
  extend self

  TIME_PART_PER_DAY = 8
  OPEN_WEATHER_PATH = "http://api.openweathermap.org/data/2.5"
  CITIES = ['London', 'Paris', 'Amsterdam', 'Minsk', 'Kyiv', 'Berlin', 'Rome',
    'Sofia', 'Vienna', 'Budapest']

  def get_daily_forecast
    CITIES.each_with_object([]) do |city, result|
      params = { q: city, mode: 'xml', units: 'metric',
                 APPID: Rails.application.credentials.open_weather_app_id }

      url = URI.parse("#{OPEN_WEATHER_PATH}/forecast?#{params.to_query}")
      request = Net::HTTP::Get.new(url.to_s)
      response = Net::HTTP.start(url.host, url.port) do |http|
        http.request(request)
      end

     result << parse_xml(response.body)
    end.flatten
  end

  def get_file(type)
    forecast = get_daily_forecast

    if type == 'json'
      JSON.pretty_generate(forecast)
    elsif type == 'csv'
      CSV.generate do |csv|
        csv << forecast.first.keys

        forecast.each do |f|
          csv << f.values
        end
      end
    end
  end

  private

  # convert required fields from xml to json array
  def parse_xml(body)
    xml = Nokogiri::XML(body)
    array = []

    times = xml.xpath('//forecast/time')[0...TIME_PART_PER_DAY]
    times.each_with_index do |t, index|
      array[index] = {}
      array[index][:city]          = t.at_xpath('//location/name/text()').to_s
      array[index][:timeFrom]      = t.at_xpath('@from').to_s
      array[index][:timeTo]        = t.at_xpath('@to').to_s
      array[index][:windDirection] = t.at_xpath('windDirection/@name').to_s
      array[index][:windSpeed]     = t.at_xpath('windSpeed/@mps').to_s + ' mps'
      array[index][:temperature]   = t.at_xpath('temperature/@value').to_s +
        ' ' + t.at_xpath('temperature/@unit').to_s
      array[index][:pressure]      = t.at_xpath('pressure/@value').to_s +
        ' ' + t.at_xpath('pressure/@unit').to_s
      array[index][:humidity]      = t.at_xpath('humidity/@value').to_s +
        + t.at_xpath('humidity/@unit').to_s
    end
    array
  end
end
