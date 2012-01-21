class UsersController < ApplicationController

  respond_to :json

  def index
    @users = User.all

    respond_with(@users)
  end

  # POST /users.json
  def create
    @user = User.new(params[:user])
    @user.save

    respond_with(@user)
  end
  
  # PUT /users/id.json
  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:post])

    respond_with(@user)
  end

end
