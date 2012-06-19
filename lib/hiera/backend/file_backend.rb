class Hiera
  module Backend
    class File_backend
      def initialize
        Hiera.debug("Hiera File_backend: starting")
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = nil

        Hiera.debug("Hiera File_backend: looking up '#{key}'")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Hiera File_backend: looking for data source '#{source}'")
          datadir = File.expand_path(Backend.datafile(:file, scope, source, "d")) || next
          path = File.expand_path(File.join(datadir, key))
          unless path.index(datadir) == 0
            raise Exception, "Hiera File_backend: key lookup outside of datadir '#{key}'"
          end
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
