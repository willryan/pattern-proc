require 'metaclass'

module PatternProc
  module TestMethods
    def pattern(method)
      @__patterns ||= {}
      PatternProcPatterns.find_or_create_pattern @__patterns, self.__metaclass__, method
    end
  end
end
