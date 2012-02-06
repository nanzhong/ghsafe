class RoutesController < ApplicationController

  respond_to :json
  respond_to :html, :only => [:track, :index]
  respond_to :js, :only => [:update_tracking]

  def create
    @user = User.find(params[:route][:user][:id])
    params[:route].delete :user
    @route = @user.routes.create(params[:route])
    @route.save

    respond_with(@route)
  end

  def index
    @routes = Route.all
  end

  def track
    @route = Route.find(params[:route_id])

    render :layout => 'track'
  end

  def update_tracking
    @route = Route.find(params[:route_id])

  end

end
