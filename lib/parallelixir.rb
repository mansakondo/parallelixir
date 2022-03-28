# frozen_string_literal: true

require_relative "parallelixir/version"

module Parallelixir
  require "parallelixir/job"
  require "parallelixir/railtie" if defined? Rails::Railtie

  require "redis"
  require "connection_pool"

  class << self
    def redis
      @redis ||= ConnectionPool.new(size: 5) { Redis.new }
    end

    def redis=(config)
      if config.is_a? ConnectionPool
        @redis = config
      else
        @redis = Redis.new(config)
      end
    end

    def configure
      yield self if block_given?
    end
  end
end
