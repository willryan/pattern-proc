require 'pattern_proc'

class TestObjectClass
  include PatternProc
  def my_func(a,b,c)
    raise "don't call me"
  end

  pattern(:p_func).with(3,2).returns(5)
  pattern(:p_func).with do |x,y| x * y end
end

class TestSingletonClass
  class << self
    include PatternProc
    def class_func(a,b,c)
      raise "don't call me"
    end

    pattern(:p_cls_func).with(3) do |y| y * y * y end
    pattern(:p_cls_func).with do |x, y| x + y end
  end
end

describe "pattern object methods" do
  context "class" do
    let (:obj) { TestObjectClass.new }
    context "in declaration" do
      it "allows declaration of pattern methods in a class" do
        obj.p_func(3,2).should == 5
        obj.p_func(3,3).should == 9
      end
    end
    context "after the fact" do
      it "allows replacing methods on an instance" do
        obj.pattern(:my_func).with(1,2,3).returns(7)
        obj.pattern(:my_func).with(2,3,4).returns(9)

        obj.my_func(1,2).(3).should == 7
        obj.my_func(2).(3,4).should == 9
      end

      it "allows declaring new methods on an instance" do
        obj.pattern(:new_func).with(:a, :b).returns(:c)
        obj.pattern(:new_func).with(:d, :e).returns(:f)

        obj.new_func(:a).(:b).should == :c
        obj.new_func(:d,:e).should == :f
      end
    end
  end

  context "object" do
    let (:klass) { TestSingletonClass }
    context "in declaration" do
      it "allows declaration of pattern class methods in a class" do
        klass.p_cls_func(3,2).should == 8
        klass.p_cls_func(9,3).should == 12
      end
    end

    context "after the fact" do
      it "allows replacing methods on a class" do
        klass.pattern(:class_func).with(1,2,3).returns(7)
        klass.pattern(:class_func).with(2,3,4).returns(9)

        klass.class_func(1,2).(3).should == 7
        klass.class_func(2).(3,4).should == 9
      end

      it "allows declaring new methods on an instance" do
        klass.pattern(:new_func).with(:a, :b).returns(:c)
        klass.pattern(:new_func).with(:d, :e).returns(:f)

        klass.new_func(:a).(:b).should == :c
        klass.new_func(:d,:e).should == :f
      end
    end
  end
end
