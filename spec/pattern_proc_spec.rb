describe PatternProc do
  subject { described_class.new }

  it "simple" do
    subject.with(3,4).returns(12)

    prc = subject.to_proc
    prc.(3,4).should == 12
    prc.(3).(4).should == 12
  end

  it "works" do
    subject.with(3,1,2).returns(12)
    subject.with(4,4,1).returns(10)
    subject.with(7,7,7).returns(777)
    subject.with(7,7) do |l_arg|
      140 + l_arg
    end
    subject.with(7,3,4).returns(11)
    subject.with(2) do |x, y| 2 * x * y end
    subject.with do |x, y, z| 
      x * (y + z) 
    end

    prc = subject.to_proc

    prc.(3,1,2).should == 12
    prc.(3).(1,2).should == 12
    prc.(3).(1).(2).should == 12
    prc.(3,1).(2).should == 12

    prc.(4,4,1).should == 10
    prc.(4,4,2).should == 24
    prc.(4,4).(2).should == 24
    prc.(4).(4,2).should == 24

    prc.(7,7,7).should == 777
    prc.(7).(7).(7).should == 777
    prc.(7).(7,7).should == 777

    prc.(7,7,3).should == 143
    prc.(7).(7,3).should == 143
    prc.(7,7).(3).should == 143
    prc.(7).(7).(3).should == 143

    prc.(2,1,1).should == 2
    prc.(2,3).(8).should == 48

    prc.(5,6,7).should == 65
    prc.(5).(6,7).should == 65
    prc.(5).(6).(7).should == 65
    prc.(5,6).(7).should == 65
  end
end
