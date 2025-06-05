module Api
  class HealthController < ApplicationController
    # No need to skip verify_authenticity_token as we're using API mode
    # No need to skip authenticate_user! as we're using API mode

    def show
      render json: { status: 'ok', timestamp: Time.current }
    end
  end
end 