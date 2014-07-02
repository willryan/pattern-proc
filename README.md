pattern-proc
============

pattern matching Proc definitions

pattern-proc is a Ruby gem designed to allow creation of pattern-matching procs in a repeated declaration mechanism similar to Haskell.

Usage:

    require 'pattern-proc'

* manually instantiate a proc

      cool_proc = PatternProc.new
      cool_proc.with(5,10).returns(30)
      cool_proc.with(3,70).returns(111)
      cool_proc.with(3) do |second_arg|
        second_arg * 10
      end
      cool_proc.with do |first_arg, second_arg| do
        first_arg * second_arg
      end

      # later...

      regular_proc = cool_proc.to_proc
      regular_proc.(5,10)
      \> 30
      regular_proc.(3).(70)
      \> 111
      regular_proc.(3).(15)
      \> 150 # second_arg * 10 case
      regular_proc.(5,5)
      \> 25 # first_arg * second_arg case

* declare methods in a class

      class MyClass
        include PatternProc::ClassMethods
    
        pattern(:my_func).with(3,10).returns(30)
        pattern(:my_func).with(4,11).returns(40)
      end

      # later...

      obj = MyClass.new
      obj.my_func(3,10)
      \> 30
      obj.my_func(4).(11)
      \> 40

      # or

      class MySingletonClass
        class << self
          include PatternProc::ClassMethods
          pattern(:my_class_func).with(:a, :b).returns(:c)
          pattern(:my_class_func).with(:c) do |other|
            other.to_s
          end
        end
      end

* "mock" out Funkify-style partial application methods in tests

      include PatternProc::TestMethods
      
      describe 'something' do
        it '"mocks" methods' do
          mock_obj = mock 'anything'
          mock_obj.pattern(:my_func).with(1,2).returns(10)
          mock_obj.pattern(:my_func).with(1) do |x| x + 3 end
          
          mock_obj.my_func(1).(2).should == 10
          mock_obj.my_func(1,5).should == 8
          
          SomeClass.pattern(:existing_func).with("hello").returns("goodbye")
          
          SomeClass.exsting_func("hello").should == "goodbyes"
        end
      end

This gem was initially created to ease testing when using the Funkify gem, as is most clear in the last example.  However I would like to build on this library and make the ClassMethods "DSL" more robust. Additionally, right now pattern matching is done by specificity rather than declaration order, and you can only define a proc implementation for the rightmost N arguments (as opposed to any set of arguments, eg.   

    do_stuff 5 x = x * 2
in Haskell).  Finally I would like PatternProc to subclass Proc directly rather than requiring a call to to_proc.