require "securerandom"
require "json"

module Parallelixir::Job
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def perform_now(*args)
      new.perform(*args)
    end

    def perform_later(*args, **options)
      payload = {
        "id"    => SecureRandom.uuid,
        "queue" => queue,
        "type"  => self.to_s,
        "args"  => args
      }

      enqueue(**payload)
    end

    def enqueue(**payload)
      redis.then do |conn|
        conn.multi do |transaction|
          transaction.rpush(payload["queue"], payload.to_json)
          transaction.publish("parallelixir:notifications", "New job enqueued")
        end
      end
    end

    def enqueued_jobs
      enqueued = redis.then do |conn|
        conn.lrange(queue, 0, -1)
      end

      enqueued.select { |job| JSON.parse(job)["type"] == self.to_s }
    end

    def queue_as(name)
      class_variable_set :@@queue, "parallelixir:queue:#{name}"
    end

    def queue
      queue_as "default" unless class_variable_defined?(:@@queue)

      class_variable_get :@@queue
    end

    def redis
      Parallelixir.redis
    end
  end
end
