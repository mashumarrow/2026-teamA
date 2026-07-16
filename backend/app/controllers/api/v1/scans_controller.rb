module Api
  module V1
    class ScansController < BaseController
      before_action :authenticate_api_key!

      def create
        idm = FelicaCard.normalize_idm(params[:idm])
        return render_error("IDm is required", "IDM_REQUIRED", :bad_request) if idm.blank?

        card = FelicaCard.find_by(idm: idm)
        return render_error("User not found for this card", "CARD_NOT_FOUND", :not_found) unless card

        log = RoomAccessService.new(card.user).record!
        playback_result = log.in? ? AlexaQueueService.new.play_next_track : nil
        update_roulette_state!(playback_result, card.user) if playback_result.present?

        render json: {
          status: "success",
          user_name: card.user.name,
          action: log.action_type,
          timestamp: log.timestamp.iso8601,
          playback: playback_result
        }
      rescue StandardError => e
        Rails.logger.error("[scan] #{e.class}: #{e.message}")
        render_error("Failed to process scan", "SCAN_FAILED", :internal_server_error)
      end

      private

      def update_roulette_state!(playback_result, user)
        RouletteState.update!(
          playback_result.merge(
            phase: playback_result[:status] == "success" ? "playing" : "result",
            updated_by: user.name
          )
        )
      end
    end
  end
end
