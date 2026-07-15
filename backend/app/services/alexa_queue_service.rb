class AlexaQueueService
  MIN_WEIGHT_MINUTES = 1.0

  def play_next_track(device_id: nil)
    candidates = candidate_users
    return error("No IC card registered users", "NO_CARD_REGISTERED_USERS") if candidates.empty?

    weights = selection_weights(candidates)
    selected_user = weighted_select(candidates, weights)
    track = selected_user.spotify_account&.spotify_tracks&.sample

    if track.blank?
      return no_track_result(selected_user, weights)
    end

    track_uri = "spotify:track:#{track.spotify_track_id}"

    playback = SpotifyPlayerService.new.play_track!(track_uri, device_id: device_id)
    return playback_error(playback, selected_user, track, track_uri, weights) unless playback[:status] == "success"

    SpotifyPlayEvent.create!(user: selected_user, spotify_track: track, selected_at: Time.current)

    {
      status: "success",
      selected_user: selected_user.name,
      selected_user_id: selected_user.id,
      selected_track: "#{track.track_name} - #{track.artist_name}",
      spotify_track_id: track.spotify_track_id,
      duration_ms: track.duration_ms,
      track_uri: track_uri,
      probability: probability_for(selected_user, weights),
      roulette_candidates: roulette_candidates(candidates, weights),
      timestamp: Time.current.iso8601
    }
  end

  private

  def candidate_users
    User.includes(:room_access_logs, :felica_cards, spotify_account: :spotify_tracks)
        .joins(:felica_cards)
        .distinct
        .to_a
  end

  def selection_weights(users)
    users.each_with_object({}) do |user, result|
      result[user.id] = weekly_stay_minutes(user)
    end
  end

  def weekly_stay_minutes(user)
    now = Time.current
    start_time = now.beginning_of_week
    logs = user.room_access_logs.where("timestamp >= ?", start_time - RoomAccessSummary::MAX_OPEN_SESSION).to_a
    minutes = RoomAccessSummary.new(logs, now).duration_between(start_time, now).to_f / 60.0

    [minutes, MIN_WEIGHT_MINUTES].max
  end

  def weighted_select(users, weights)
    total = weights.values.sum
    threshold = rand * total
    cumulative = 0.0

    users.each do |user|
      cumulative += weights[user.id].to_f
      return user if threshold <= cumulative
    end

    users.last
  end

  def probability_for(user, weights)
    total = weights.values.sum.to_f
    return 0 if total.zero?

    (weights[user.id].to_f / total).round(4)
  end

  def roulette_candidates(users, weights)
    users.map do |user|
      {
        user_id: user.id,
        name: user.name,
        week_minutes: weights[user.id].to_f.round(1),
        probability: probability_for(user, weights)
      }
    end
  end

  def no_track_result(selected_user, weights)
    users = candidate_users
    {
      status: "no_track",
      message: "お気に入りされている登録がありません。楽曲のお気に入り登録お願いします。",
      selected_user: selected_user.name,
      selected_user_id: selected_user.id,
      selected_track: nil,
      spotify_track_id: nil,
      duration_ms: nil,
      track_uri: nil,
      probability: probability_for(selected_user, weights),
      roulette_candidates: roulette_candidates(users, weights),
      timestamp: Time.current.iso8601
    }
  end

  def playback_error(playback, selected_user, track, track_uri, weights)
    playback.merge(
      selected_user: selected_user.name,
      selected_user_id: selected_user.id,
      selected_track: "#{track.track_name} - #{track.artist_name}",
      spotify_track_id: track.spotify_track_id,
      duration_ms: track.duration_ms,
      track_uri: track_uri,
      probability: probability_for(selected_user, weights),
      roulette_candidates: roulette_candidates(candidate_users, weights),
      timestamp: Time.current.iso8601
    )
  end

  def error(message, code)
    { status: "error", message: message, code: code }
  end
end
