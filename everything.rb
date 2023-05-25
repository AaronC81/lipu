require 'win32api'

module Everything
    DLL_PATH = File.join(__dir__, 'dll', 'Everything32.dll')

    class Result
        attr_accessor :file_name, :path

        def initialize(**kw)
            kw.each { |k, v| send("#{k}=", v) }
        end
    end

    class Query
        attr_accessor :search

        def execute
            Everything.execute_query self
        end
    end

    def self.results
        count = dll_function("Everything_GetNumResults", [], "L").()
        Enumerator.new(count) do |e|
            count.times do |i|
                e << Result.new(
                    file_name: dll_function("Everything_GetResultFileName", ["I"], "P").(i).to_s,
                    path: dll_function("Everything_GetResultPath", ["I"], "P").(i).to_s,
                )
            end
        end
    end

    def self.db_loaded?
        !!dll_function("Everything_IsDBLoaded", [], "I").()
    end

    def self.version
        "#{major_version}.#{minor_version}.#{revision}.#{build_number}"
    end

    def self.major_version
        check_error dll_function("Everything_GetMajorVersion", [], "L").()
    end

    def self.minor_version
        check_error dll_function("Everything_GetMinorVersion", [], "L").()
    end

    def self.revision
        check_error dll_function("Everything_GetRevision", [], "L").()
    end

    def self.build_number
        check_error dll_function("Everything_GetBuildNumber", [], "L").()
    end

    def self.execute_query(query)
        raise TypeError unless query.is_a?(Query)

        dll_function("Everything_Reset", [], "V").()
        dll_function("Everything_SetSearch", ["P"], "V").(query.search) if query.search

        # TODO: make non-blocking?
        dll_function("Everything_Query", ["I"], "L").(1)
    end

    private_class_method def self.last_error
        dll_function("Everything_GetLastError", [], "L").()
    end

    private_class_method def self.dll_function(name, args, ret)
        @@cached_dll_functions ||= {}
        unless @@cached_dll_functions.has_key?(name)
            @@cached_dll_functions[name] = Win32API.new(DLL_PATH, name, args, ret)
        end

        @@cached_dll_functions[name]
    end

    private_class_method def self.check_error(ret)
        raise "Everything API returned error code: #{last_error}" if ret == 0

        ret
    end
end

query = Everything::Query.new
query.search = "everything"
query.execute
p Everything.results.to_a
