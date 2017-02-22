class ApiController < ApplicationController

	before_action :check_key

    def unknown
        render json: "[0a] Unknown API endpoint."
    end

    def nokey
        render json: "[0b] No API key provided."
    end

    def badkey
        render json: "[0c] Invalid API key provided."
    end

    private

    def check_key
    	if params[:apikey].nil?
    		nokey()
    	elsif !key_valid(params[:apikey])
    		badkey()
    	end
    	true # the key is valid.
    end

    def key_valid(key) # TODO: implement this
    	false
    end
    
end
