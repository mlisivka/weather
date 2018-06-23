require 'open_weather_api'

class HomeController < ApplicationController
  def index
    @forecast = OpenWeatherApi.get_daily_forecast
  end

  def download_forecast
    type = params[:type]
    send_data OpenWeatherApi.get_file(type),
      filename: "forecast.#{type}",
      type: define_content_type(type)
  end

  private

  def define_content_type(type)
    case type
      when 'json'
        'application/json'
      when 'csv'
        'text/csv'
      else
        'text/plain'
    end
  end
end
