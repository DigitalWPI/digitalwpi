# frozen_string_literal: true

AUTH_CONFIG = YAML.load_file(Rails.root.join('config', 'authentication.yml'))[Rails.env]
