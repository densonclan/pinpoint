class PostcodeSectorsController < ApplicationController

  def index
    @sectors = PostcodeSector.ordered.page params[:page]
    respond_to do |r|
      r.html
      r.js { render partial: 'search' }
    end
  end

  def search
    sectors = PostcodeSector.ordered.search(params[:term]).limit 30
    render json: sectors.map {|s| {label: s.to_s, value: s.id}}
  end
end