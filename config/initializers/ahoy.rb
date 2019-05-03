class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = true

# better user agent parsing
Ahoy.user_agent_parser = :device_detector

# better bot detection
Ahoy.bot_detection_version = 2

# :when_needed will create visits server-side only when needed by events,
# and false will disable server-side creation completely, discarding events
# without a visit
Ahoy.server_side_visits = :false
