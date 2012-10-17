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
    @routes = Route.sort(:date.desc).all
  end

  def track
    @route = Route.find(params[:route_id])

    @last_location = @route.locations.sort(:date.desc).limit(1).first

    @recent_locations = []
    num = 0
    addresses = []
    @route.locations.sort(:date.desc).limit(100).each do |l|
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
    @locations = @route.locations.where(:date => {:$gte => @after}).sort(:date.desc)
    @prev_location = @locations.all.pop
    @locations = @locations.all

    @recent_locations = []
    addresses = [@prev_location.address]
    @locations.each do |l|
      unless addresses.include?(l.address)
        addresses << l.address
        @recent_locations << l
      end
    end
  end

  def destroy
    @route = Route.find(params[:id])
    @route.locations.delete_all
    @route.delete

    redirect_to routes_url
  end

end
