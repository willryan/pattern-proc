require 'pattern-proc/pattern_proc_case'

module PatternProc
  class PatternProc

    def initialize(cases = [])
      @arity = -1
      @cases = []
      cases.each do |c| add_case c end
    end

    def with(*args, &block)
      case_obj = PatternProcCase.new(args, &block)
      add_case case_obj
      case_obj
    end

    def to_proc
      ->(*args) { call(args) }
    end

    private
    def add_case(case_obj)
      if @arity == -1
        @arity = case_obj.arity
      elsif @arity != case_obj.arity
        raise "mismatched arity"
      end
      @cases << case_obj
    end


    def call(args)
      if args.size == @arity
        best_match = find_matches(args, true).first
        if best_match
          best_match.to_proc.call(args)
        else
          raise "no match"
        end
      elsif args.size < @arity
        sliced_cases = find_matches(args, false)
        if sliced_cases.size > 0
          PatternProc.new(sliced_cases).to_proc
        else
          raise "no match"
        end
      else
        raise "too many args"
      end
    end

    def find_matches(args, stop_at_first_match)
      results = []
      sorted_cases = @cases.sort do |case_obj_1, case_obj_2|
        case_obj_1.specificity <=> case_obj_2.specificity
      end.reverse
      sorted_cases.each do |case_obj|
        result = case_obj.make_subcase(args)
        if result
          results << result
          if stop_at_first_match
            break
          end
        end
      end
      results
    end
  end
end
