module Api
  class HealthController < ApplicationController
    # No need to skip verify_authenticity_token as we're using API mode
    # No need to skip authenticate_user! as we're using API mode

    def show
      Rails.logger.info "Health check requested at #{Time.current}"
      Rails.logger.info "Request headers: #{request.headers.to_h.select { |k,v| k.start_with?('HTTP_') }}"
      Rails.logger.info "Request host: #{request.host}"
      Rails.logger.info "Request port: #{request.port}"
      
      render json: { 
        status: 'ok', 
        timestamp: Time.current,
        environment: Rails.env,
        host: request.host,
        port: request.port
      }
    end
  end
end 