class OddsController < ApplicationController

    def index
        @odds = Odd.all
    end

    def show
        @odds = Odd.all
    end
end