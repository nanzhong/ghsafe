class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :require_authentication

  private 
  def require_authentication
    params.each do |k, v|
      puts "#{k}:#{v}"
    end
  end

end
