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
    lat = params[:lat]
    long = params[:long]

    @reports = Report.where(:latitude => {:$gt => lat - 0.25, :$lt => lat + 0.25}, :longitude => {:$gt => long - 0.25, :$lt => long + 0.25})

    respond_with(@reports)
  end

end
