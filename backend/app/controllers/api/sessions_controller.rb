class Api::SessionsController < ApplicationController
  def index
    @sessions = Session.all
    render json: @sessions.to_a
  end

  def show
  end

  def create
  end
end
