class VideosController < ApplicationController

  respond_to :json

  def create
    @route = Route.find(params[:route_id])
    @video = Video.new(params[:video])
    @route.videos << @video
    @route.save

    respond_with(@video, :location => nil)
  end

  def play
    @video = Route.find(params[:route_id]).videos.find(params[:video_id])

    send_data @video
  end

end
