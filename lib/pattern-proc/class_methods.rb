module PatternProc
  module ClassMethods
    def self.included(klass)
      klass.extend JustClassMethods
    end
  end

  module JustClassMethods
    def pattern(method)
      @__patterns ||= {}
      PatternProcPatterns.find_or_create_pattern @__patterns, self, method
    end
  end
end
