require 'hiera/config'

class Hiera
  module Backend
    class File_backend
      def initialize
        Hiera.debug("Hiera File backend starting")

        if Hiera::Config.include?(:file) and Hiera::Config[:file].has_key? :interpolate
          @interpolate = Hiera::Config[:file][:interpolate]
        else
          @interpolate = true
        end
      end

      if Gem::Version.new(Hiera.version) < Gem::Version.new('2')
        def lookup(key, scope, order_override, resolution_type)
          answer = nil

          Hiera.debug("Looking up #{key} in File backend")

          Backend.datasources(scope, order_override) do |source|
            Hiera.debug("Hiera File_backend: looking for data source '#{source}'")

            datadir = Backend.datafile(:file, scope, source, "d") or next

            validate_key_lookup!(datadir, key)

            path = File.join(datadir, key)
            next unless File.exist?(path)

            data = IO.binread(path)

            case resolution_type
            when :array
              answer ||= []
              answer << parse_answer(data, scope)
            else
              answer = parse_answer(data, scope)
              break
            end
          end

          answer
        end
      else
        def lookup(key, scope, order_override, resolution_type, context)
          if Gem::Version.new(Hiera.version) >= Gem::Version.new('2') and Gem::Version.new(Hiera.version) < Gem::Version.new('3.1.0')
	    Hiera.warn("Hiera File_backend: file extensions unsupported by Hiera version")
          end
          answer = nil
          found = false

          Hiera.debug("Looking up #{key} in File backend")

          Backend.datasources(scope, order_override) do |source|
            Hiera.debug("Hiera File_backend: looking for data source '#{source}'")

            datadir = Backend.datafile(:file, scope, source, "d") or next

            validate_key_lookup!(datadir, key)

            path = File.join(datadir, key)
            next unless File.exist?(path)

            data = File.read(path)
            found = true

            case resolution_type
            when :array
              answer ||= []
              answer << parse_answer(data, scope, {}, context)
            else
              answer = parse_answer(data, scope, {}, context)
              break
            end
          end

          throw :no_such_key unless found
          return answer
        end

        # because hiera 3 interprets . as a segment delimeter we can override this behaviour with this method
        def lookup_with_segments(segments, scope, order_override, resolution_type, context)
          return lookup(segments.join('.'), scope, order_override, resolution_type, context)
        end
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

      # Parse the answer according to the chosen interpolation mode
      #
      # @param data  [String] The value to parse
      # @param scope [Hash] The variable scope to use for interpolation
      #
      # @return [String] The interpolated data
      if Gem::Version.new(Hiera.version) < Gem::Version.new('2')
        def parse_answer(data, scope)
          if @interpolate
            Backend.parse_answer(data, scope)
          else
            data
          end
        end
      else
        def parse_answer(data, scope, extras, context)
          if Gem::Version.new(Hiera.version) >= Gem::Version.new('2') and Gem::Version.new(Hiera.version) < Gem::Version.new('3.1.0')
  	    Hiera.debug("Hiera File_backend: file extensions unsupported by Hiera version")
          end
          if @interpolate
            Backend.parse_answer(data, scope, extras, context)
          else
            data
          end
        end
      end
    end
  end
end
