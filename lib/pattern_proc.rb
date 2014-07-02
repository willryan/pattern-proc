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

class Object
  def partials(method)
    @__partials ||= {}
    unless @__partials[method] 
      proc_obj = PatternProc.new
      metaclass = class << self; self; end
      metaclass.class_eval do
        define_method(method) do |*args|
          curried_method = proc_obj.to_proc.curry
          curried_method[*args]
        end
      end
      @__partials[method] = proc_obj
    end
    @__partials[method]
  end
end
