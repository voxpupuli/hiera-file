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
          Hiera.debug("Hiera File_backend: looking for data source '#{source}'")

          datadir = Backend.datafile(:file, scope, source, "d") or next

          validate_key_lookup!(datadir, key)

          path = File.join(datadir, key)
          next unless File.exist?(path)

          data = File.read(path)

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

      # Ensure that looked up files are within the datadir to prevent directory traversal
      #
      # @param datadir [String] The directory being used for the lookup
      # @param key     [String] The key being looked up
      #
      # @todo Raise a SecurityError instead of an Exception
      # @raise [Exception] If the path to the data file is outside of the datadir
      def validate_key_lookup!(datadir, key)

        # Expand the datadir and path, and ensure that the datadir contains
        # the given key. If the expanded key is outside of the datadir then
        # this is a directory traversal attack and should be aborted.
        abs_datadir = File.expand_path(datadir)
        abs_path    = File.expand_path(File.join(abs_datadir, key))
        unless abs_path.index(abs_datadir) == 0
          raise Exception, "Hiera File backend: key lookup outside of datadir '#{key}'"
        end
      end
    end
  end
end
