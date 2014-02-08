shared_examples Hdo::Model::FixedDateRange do
  it 'knows the current instance' do
    obj = described_class.make! start_date: 1.month.ago, end_date: 1.month.from_now
    described_class.current.should == obj
  end

  it 'finds the instance at a given date' do
    obj = described_class.make! start_date: 2.months.ago, end_date: 1.month.ago
    described_class.for_date(40.days.ago).should == obj
  end

  it 'has a name' do
    start_date = 5.years.ago
    end_date   = 1.year.ago

    obj = described_class.make! start_date: start_date, end_date: end_date
    obj.name.should == "#{start_date.year}-#{end_date.year}"
  end

  it 'knows the previous, current and next instances' do
    ps2011 = described_class.make! start_date: Date.new(2011, 10, 1), end_date: Date.new(2012, 9, 30)
    ps2012 = described_class.make! start_date: Date.new(2012, 10, 1), end_date: Date.new(2013, 9, 30)
    ps2013 = described_class.make! start_date: Date.new(2013, 10, 1), end_date: Date.new(2014, 9, 30)
    ps2014 = described_class.make! start_date: Date.new(2014, 10, 1), end_date: Date.new(2015, 9, 30)

    Date.stub(:current => Date.new(2013, 11, 1))
    expect(described_class.previous).to eq(ps2012)
    described_class.current.should == ps2013
    described_class.next.should == ps2014

    Date.stub(:current => Date.new(2014, 5, 1))
    described_class.previous.should == ps2012
    described_class.current.should == ps2013
    described_class.next.should == ps2014
  end
end