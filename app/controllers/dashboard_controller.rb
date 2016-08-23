class DashboardController < ApplicationController

  def index
    respond_to do |r|
      r.js
      r.html
    end
  end
end