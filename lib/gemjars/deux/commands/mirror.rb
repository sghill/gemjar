require 'clamp'
require 'gemjars/deux/file_store'

module Gemjars
  module Deux
    module Commands
      class Mirror < ::Clamp::Command
        include Commands::Dsl

        option ["-w", "--workers"], "WORKERS", "worker count", :attribute_name => :workers_count, :default => 5 do |s|
          Integer(s)
        end

        option ["--out"], "OUTPUT_DIRECTORY", "output directory", :attribute_name => :output_directory, :required => true

        option ["--log"], "LOG_PATH", "log file path", :default => File.new(File.expand_path("log"), "w+") do |s|
          File.new(s, "w+")
        end

        def http
          @http ||= Http.default
        end

        def specs
          @specs ||= Specifications.rubygems + Specifications.prerelease_rubygems
        end

        def store
          @store ||= FileStore.new(output_directory)
        end

        def repo
          @repo ||= MavenRepository.new(store)
        end

        def index
          @index = Index.spawn(store)
        end

        def execute
          require 'thread'
          require 'celluloid/autostart'

          Celluloid.logger = Logger.new(log)

          task_queue = PriorityQueue.new(specs)

          specs.each { |s| task_queue << s }

          pool = (1..workers_count).to_a.map do |i|
            Gemjars::Deux::Worker.spawn("Worker #{i}", task_queue, index, http, repo, specs)
          end

          workers = Workers.new(task_queue, pool)

          Signal.trap("INT") do
            workers.halt!
            exit
          end

          workers.run!
        end
      end
    end
  end
end

