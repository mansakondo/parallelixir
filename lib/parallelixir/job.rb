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

    def perform_later(*args, wait: nil)
      payload = {
        "id"    => SecureRandom.uuid,
        "queue" => queue,
        "type"  => self.to_s,
        "args"  => args
      }

      if wait
        timestamp = Time.now.to_i.in_milliseconds

        if wait.respond_to? :to_time
          schedule_time = wait
            .to_time
            .to_i
            .in_milliseconds
        else
          schedule_time = wait
            .to_i
            .in_milliseconds
        end

        real_schedule_time = schedule_time + timestamp

        schedule(real_schedule_time, **payload)
      else
        enqueue(**payload)
      end
    end

    def enqueue(**payload)
      redis.then do |conn|
        conn.multi do |transaction|
          transaction.rpush(payload["queue"], payload.to_json)
          transaction.publish("parallelixir:notifications", { message: "New job enqueued" }.to_json)
        end
      end
    end

    def schedule(schedule_time, **payload)
      redis.then do |conn|
        conn.multi do |transaction|
          transaction.zadd("parallelixir:scheduled-jobs", schedule_time, payload.to_json)
          transaction.publish("parallelixir:notifications", { message: "New job scheduled", schedule_time: schedule_time }.to_json)
        end
      end
    end

    def enqueued_jobs
      enqueued = redis.then do |conn|
        conn.lrange(queue, 0, -1)
      end

      enqueued.select do |payload|
        JSON.parse(payload)["type"] == self.to_s
      end
    end

    def scheduled_jobs
      scheduled = redis.then do |conn|
        conn.zrange("parallelixir:scheduled-jobs", 0, -1, with_scores: true)
      end

      scheduled.select do |payload, _schedule_time|
        JSON.parse(payload)["type"] == self.to_s
      end
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
