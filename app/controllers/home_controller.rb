require 'open_weather_api'

class HomeController < ApplicationController
  def index
    mode = params[:mode]
    response = OpenWeatherApi.get_daily_forecast()

    render :json => response
  end
end
