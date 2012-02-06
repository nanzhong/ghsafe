class LocationsController < ApplicationController

  respond_to :json

  def create
    @route = Route.find(params[:route_id])

    # XXX - problem with reskit serializing nsnumber to nsstring
    #params[:location][:latitude] = params[:location][:latitude].to_f
    #params[:location][:longitude] = params[:location][:longitude].to_f

    location_hash = { :latitude => params[:latitude], 
                      :longitude => params[:longitude], 
                      :date => params[:date] }

    @location = Location.new(location_hash)

    @location.image = params[:image].tempfile unless params[:image].nil?

    @route.locations << @location
    @route.save

    respond_with(@location, :location => nil)
  end

end
