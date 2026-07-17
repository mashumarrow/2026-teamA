module Api
  module V1
    class AccessLogsController < BaseController
      def index
        now = Time.current
        logs = current_user.room_access_logs.order(timestamp: :desc).limit(50)
        render json: {
          status: "success",
          logs: logs.as_json(only: [:id, :action_type, :timestamp]),
          room_access_rows: room_access_rows(now),
          count: logs.count
        }
      end

      private

      def room_access_rows(now)
        today_start = now.beginning_of_day
        week_start = now.beginning_of_week
        month_start = now.beginning_of_month

        User.includes(:room_access_logs).order(:name).map do |user|
          summary = RoomAccessSummary.new(user.room_access_logs, now)
          {
            user_id: user.id,
            name: user.name,
            in_room: summary.in_room?,
            current_since: summary.current_since&.strftime("%m/%d %H:%M") || "-",
            current_seconds: summary.current_duration,
            today_seconds: summary.duration_between(today_start, now),
            week_seconds: summary.duration_between(week_start, now),
            month_seconds: summary.duration_between(month_start, now)
          }
        end
      end
    end
  end
end
