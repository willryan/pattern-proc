require 'pattern-proc/pattern_proc'

module PatternProc
  class PatternProcPatterns
    class << self
      def find_or_create_pattern(patterns, receiver, method)
        unless patterns[method] 
          proc_obj = PatternProc.new
          receiver.class_eval do
            define_method(method) do |*args|
              curried_method = proc_obj.to_proc.curry
              curried_method[*args]
            end
          end
          patterns[method] = proc_obj
        end
        patterns[method]
      end
    end
  end
end
