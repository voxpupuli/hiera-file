class Hiera
  module Backend
    class File_backend
      def initialize
        Hiera.debug("Hiera File backend starting")
      end

      def lookup(key, scope, order_override, resolution_type)
        answer = nil

        Hiera.debug("Looking up #{key} in JSON backend")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Hiera File_backend: looking for data source '#{source}'")

          datadir = Backend.datafile(:file, scope, source, "d") or next

          # Expand the datadir and path, and ensure that the datadir contains
          # the given key. If the expanded key is outside of the datadir then
          # this is a directory traversal attack and should be aborted.
          abs_datadir = File.expand_path(datadir)
          abs_path    = File.expand_path(File.join(abs_datadir, key))
          unless abs_path.index(abs_datadir) == 0
            raise Exception, "Hiera File backend: key lookup outside of datadir '#{key}'"
          end

          next unless File.exist?(abs_path)
          data = File.read(abs_path)

          case resolution_type
          when :array
            answer ||= []
            answer << Backend.parse_answer(data, scope)
          else
            answer = Backend.parse_answer(data, scope)
            break
          end
        end

        answer
      end
    end
  end
end
