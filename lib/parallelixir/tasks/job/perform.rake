namespace :parallelixir do
  namespace :job do
    desc "Perform a Parallelixir job"
    task :perform => :environment do
      require "erlectricity"
      require "active_support/json"

      receive do |port|
        port.when([:payload, String]) do |json|
          payload = ActiveSupport::JSON.decode(json)
          p payload

          job_type, job_args = payload["type"], payload["args"]

          job_args.map! do |job_arg|
            begin
              eval job_arg
            rescue
              eval job_arg.inspect
            rescue SyntaxError
              eval job_arg.inspect
            end
          end

          p "Perform #{job_type} with arguments: #{job_args}"

          eval "#{job_type}.new.perform(*#{job_args})"
        end
      end
    end
  end
end
