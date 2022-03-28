module Parallelixir
  class Railtie < Rails::Railtie
    railtie_name :parallelixir

    rake_tasks do
      lib_path = File.expand_path __dir__

      Dir["#{lib_path}/tasks/**/*.rake"].each do |task|
        load task
      end
    end
  end
end
