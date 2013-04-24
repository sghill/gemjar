require 'yaml'
require 'celluloid'
require 'set'

module Gemjars
  module Deux
    class Index
      include Celluloid

      finalizer :flush

      def initialize store
        @store = store
        @index = load_index
      end

      def handled? spec
        @index.include?(spec)
      end

      def add spec
        @index << spec
      end

      def flush
        out = @store.put("index.yml")
        out << YAML.dump(@index)
      ensure
        out.close
      end

      private
      
      def load_index
        io = @store.get("index.yml")
        io ? Set.new(YAML.load(io)) : Set.new
      end
    end
  end
end

