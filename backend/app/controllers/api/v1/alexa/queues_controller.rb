module Api
  module V1
    module Alexa
      class QueuesController < BaseController
        def show
          render json: RouletteState.current
        end

        def create
          result = AlexaQueueService.new.play_next_track(device_id: params[:device_id])
          RouletteState.update!(result.merge(phase: result[:status] == "success" ? "playing" : "result", updated_by: current_user&.name))
          render json: result, status: %w[success no_track].include?(result[:status]) ? :ok : :bad_request
        end

        def update_state
          state = RouletteState.update!(roulette_state_params.merge(updated_by: current_user&.name))
          render json: state
        end

        private

        def roulette_state_params
          params.permit(
            :phase,
            :message,
            :selected_user,
            :selected_user_id,
            :selected_track,
            :status,
            :duration_ms,
            roulette_candidates: [:user_id, :name, :week_minutes, :probability]
          ).to_h.deep_symbolize_keys
        end
      end
    end
  end
end
