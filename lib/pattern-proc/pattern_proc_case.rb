module PatternProc
  class PatternProcCase

    attr_reader :proc_applied_level
    attr_reader :proc_arity

    def initialize(args, previous_specificity = 0, proc_arity = 0, &block)
      @expected_args = args
      @proc = block
      @proc_arity = proc_arity
      @previous_specificity = previous_specificity || 0
      if !block.nil? && block.arity > 0
        @proc_arity = block.arity
      end
    end

    def returns(value)
      @return_value = value
      self
    end

    # private ish
    def expected_arity
      @expected_args.size || 0
    end

    def arity
      expected_arity + proc_arity
    end

    def specificity
      expected_arity + @previous_specificity
    end

    def make_subcase(args)
      match_len = [args.size, @expected_args.size].min
      expected = @expected_args.take(match_len)
      actual = args.take(match_len)
      if expected == actual
        new_proc = to_proc.curry
        curry_count = args.size - @expected_args.size
        new_arity = proc_arity
        if curry_count > 0
          send_args = args.drop(match_len).take(curry_count)
          new_proc = new_proc.call(*send_args)
          new_arity -= curry_count
          if new_arity == 0
            return PatternProcCase.new([], specificity).returns(new_proc)
          elsif !(new_proc.is_a?(Proc))
            raise "uh oh"
          end
        end
        PatternProcCase.new(@expected_args.drop(match_len), specificity, new_arity, &new_proc).returns(@return_value)
      else
        nil
      end
    end

    def to_proc
      @proc || ->(*args) { @return_value }
    end
  end
end
