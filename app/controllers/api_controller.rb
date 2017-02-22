class ApiController < ApplicationController

    def unknown
        render json: "[0a] Unknown API endpoint."
    end

    def nokey
        render json: "[0b] No API key provided."
    end

    def badkey
        render json: "[0c] Invalid API key provided."
    end
    
end
