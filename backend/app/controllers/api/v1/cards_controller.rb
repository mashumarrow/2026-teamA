module Api
  module V1
    class CardsController < BaseController
      before_action :require_current_user!

      def create
        idm = FelicaCard.normalize_idm(params[:idm])
        return render_error("IDm is required", "IDM_REQUIRED", :bad_request) if idm.blank?

        card = nil

        ActiveRecord::Base.transaction do
          card = FelicaCard.lock.find_or_initialize_by(idm: idm)
          card.user = current_user
          card.save!

          current_user.felica_cards.where.not(id: card.id).destroy_all
        end

        render json: {
          status: "success",
          card: card.as_json(only: [:id, :idm]),
          user: current_user.as_json(only: [:id, :name, :email])
        }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render_error(e.record.errors.full_messages.to_sentence, "CARD_INVALID", :unprocessable_entity)
      end

      private

      def require_current_user!
        return if current_user

        render_error("Login required", "LOGIN_REQUIRED", :unauthorized)
      end
    end
  end
end
