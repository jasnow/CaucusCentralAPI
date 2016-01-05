module Api
  module V1
    class PrecinctsController < ApplicationController
      skip_authorization_check only: [:index]

      def index
        precincts =
          if current_user.organizer?
            Precinct.all
          else
            current_user.precincts
          end
        render :index, locals: { precincts: precincts }
      end

      def show
        authorize! :read, current_precinct
        render :show, locals: { precinct: current_precinct }
      end

      def create
        precinct = Precinct.new(precinct_params)
        authorize! :create, precinct

        if precinct.save
          render :show, locals: { precinct: precinct }, status: :created, location: api_v1_precinct_url(precinct)
        else
          render json: precinct.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize! :update, current_precinct

        if current_precinct.update(precinct_params)
          render :show, locals: { precinct: current_precinct }, status: :ok, location: api_v1_precinct_url(current_precinct)
        else
          render json: current_precinct.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize! :destroy, current_precinct
        current_precinct.destroy

        head :no_content
      end

      private

      def current_precinct
        @current_precinct ||= Precinct.find(params[:id])
      end

      def precinct_params
        params.require(:precinct).permit(:name, :county, :supporting_attendees, :total_attendees)
      end
    end
  end
end