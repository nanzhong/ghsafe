require 'net/http'

class RoutesController < ApplicationController

  respond_to :json
  respond_to :html, :only => [:track, :index]
  respond_to :js, :only => [:update_tracking]

  def create
    @user = User.find(params[:route][:user][:id])
    params[:route].delete :user
    @route = @user.routes.create(params[:route])
    @route.save

    Notifier.notify_contacts(@user, @route).deliver

    respond_with(@route)
  end

  def index
    @routes = Route.all
  end

  def track
    @route = Route.find(params[:route_id])

    @last_location = @route.locations.last

    @recent_locations = []
    num = 0
    addresses = []
    @route.locations.reverse.each do |l|
      break if num == 20
      unless addresses.include?(l.address)
        addresses << l.address
        @recent_locations << l

        num += 1
      end
    end

    render :layout => 'track'
  end

  def update_locations
    @route = Route.find(params[:route_id])
    @after = Time.at(params[:after].to_i)
    @locations = @route.locations.select {|l| l.date > @after}
  end

end
