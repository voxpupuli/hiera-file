class Hiera
  module Backend
    class File_backend
      def initialize
        Hiera.debug("Hiera File backend starting")
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = nil

        Hiera.debug("Looking up #{key} in File backend")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          file = Backend.datafile(:file, scope, source, "d") || next
          path = File.join(file, key)
          next if ! File.exist?(path)
          data = File.read(path)
          next if ! data
          answer = data
        end
        return answer
      end
    end
  end
end
