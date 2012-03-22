class LocationsController < ApplicationController

  respond_to :json

  def image
    @route = Route.find(params[:route_id])
    @location = @route.locations.find(params[:location_id])
    
    send_data @location.image.read, :disposition => 'inline', :type => @location.image_type 
  end

  def create
    @route = Route.find(params[:route_id])

    # XXX - problem with reskit serializing nsnumber to nsstring
    #params[:location][:latitude] = params[:location][:latitude].to_f
    #params[:location][:longitude] = params[:location][:longitude].to_f

    location_hash = { :latitude => params[:latitude], 
                      :longitude => params[:longitude], 
                      :date => params[:date],
                      :address => params[:address]}

    @location = Location.new(location_hash)

    @location.image = params[:image].tempfile unless params[:image].nil?

    @location.route = @route
    @location.save

    respond_with(@location, :location => nil)
  end

end
