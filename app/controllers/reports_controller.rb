class ReportsController < ApplicationController

  respond_to :json

  def index
    @reports = Report.all

    respond_to do |format|
      format.json { render :json => @reports }
    end
  end

  # POST /reports.json
  def create
    @report = Report.new(params[:report])

    if @report.save
      respond_with(@report, :status => :created, :location => @report)
    else
      respond_with(@report.errors, :status => :unprocessable_entity)
    end
  end

  # GET /reports/search.json
  def search
    lat = params[:latitude]
    long = params[:longitude]

    if lat.nil? or long.nil?
      @reports = { :error => "must specify latitude and longitude" }
    else
      lat = lat.to_f
      long = long.to_f
      @reports = Report.where(:latitude => {:$gt => lat - 0.25, :$lt => lat + 0.25}, :longitude => {:$gt => long - 0.25, :$lt => long + 0.25})
    end

    Resque.enqueue(SpotCrimeFetcher, lat, long)

    respond_with(@reports)
  end

end
