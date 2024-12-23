# frozen_string_literal: true

require 'time'

module RuboCop
  module Cop
    module Rails
      # Checks that migration file names start with a valid timestamp.
      #
      # @example
      #   # bad
      #   # db/migrate/bad.rb

      #   # bad
      #   # db/migrate/123_bad.rb

      #   # bad
      #   # db/migrate/20171301000000_bad.rb
      #
      #   # good
      #   # db/migrate/20170101000000_good.rb
      #
      class MigrationTimestamp < Base
        include RangeHelp

        MSG = 'Migration file name must start with a valid `YYYYmmddHHMMSS_` timestamp in the past.'

        def on_new_investigation
          file_path = processed_source.file_path
          timestamp = File.basename(file_path).split('_', 2).first
          return if valid_timestamp?(timestamp)

          add_offense(source_range(processed_source.buffer, 1, 0))
        end

        private

        def valid_timestamp?(timestamp, format: '%Y%m%d%H%M%S')
          format_with_utc_suffix = "#{format} %Z"
          timestamp_with_utc_suffix = "#{timestamp} UTC"

          timestamp &&
            # Time.strptime has no way to externally declare what timezone the string is in, so we append it.
            (time = Time.strptime(timestamp_with_utc_suffix, format_with_utc_suffix)) &&
            # Time.strptime fuzzily accepts invalid dates around boundaries
            #          | Wrong Days per Month | 24th Hour      | 60th Minute    | 60th Second
            # ---------+----------------------+----------------+----------------+----------------
            # Actual   |       20000231000000 | 20000101240000 | 20000101006000 | 20000101000060
            # Expected |       20000302000000 | 20000102000000 | 20000101010000 | 20000101000100
            # We want normalized values, so we can check if Time#strftime matches the original.
            time.strftime(format) == timestamp &&
            # No timestamps in the future
            time <= Time.now.utc
        rescue ArgumentError
          false
        end
      end
    end
  end
end
