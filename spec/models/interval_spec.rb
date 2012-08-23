require 'spec_helper'

describe Interval do
	fixtures :users, :intervals
	it 'save fails with empty interval' do
	  	interval = Interval.new
	  	interval.save.should eq false
	end
	it 'save fails with empty start' do
	  	interval = Interval.new(:user => users(:testuser))
	  	interval.save.should eq false
	end
	it 'saved successfully' do
	  	interval = Interval.new(:start=>DateTime.now, :stop=>DateTime.now, :user => users(:testuser))
	  	interval.save.should eq true
	end
	it 'saved successfully with minimal data' do
	  	interval = Interval.new(:start =>DateTime.now, :user => users(:testuser))
	  	interval.save.should eq true
	end
	it 'all intervals from one day' do
		user = users(:testuser)
		start = DateTime.new(2012,7,2)
		Interval.create!(:start => DateTime.new(2012,7,1), :user=> user)
		Interval.create!(:start => start, :user=> user)
		Interval.create!(:start => start, :user=> user)
		Interval.create!(:start => DateTime.new(2012,7,3), :user=> user)
		intervals = Interval.all_intervals_in_range(Date.new(2012,7,2)..Date.new(2012,7,3),user)
		intervals.size.should eq 2
		intervals.first.start.should eq start
		intervals.last.start.should eq start
	end
		it "all intervals from today (may not work near 0 o'clock)" do
		 intervals = Interval.all_intervals_in_range Date.today..(Date.today + 1),users(:testuser)
		 intervals.should eq([intervals(:three)])
	end
	it 'all_intervals_in_range return empty array if no data is available' do
		range = Date.new(2012,7,2)..Date.new(2012,7,3)
		intervals = Interval.all_intervals_in_range(range,users(:testuser)).size.should eq 0
	end
	it 'start new successfully' do
		Interval.start_interval(users(:seconduser))
		Interval.all_intervals(users(:seconduser)).size.should eq 2
	end
	it 'diff from an interval equals 3600 secs' do
		Interval.new( :start => DateTime.new(2012,7,17,10,0), 
			:stop => DateTime.new(2012,7,17,11,0)).diff.should eq 3600
	end
	it 'diff without stop calcuates diff till now' do
		Interval.new( :start => DateTime.new(2012,7,15,10,0)).diff.should be > 0
	end
	it 'all_intervals delivers 2 entries' do
		user = User.new(:name=>'user', :password=>'pw', :worktime => 28080, :overtime => 0)
		start = DateTime.new(2012,7,2)
		Interval.create!(:start => start, :user=> user)
		Interval.create!(:start => start, :user=> user)
		Interval.all_intervals(user).size.should eq 2
	end
	it 'it finds no open intervals' do
		Interval.get_open_intervals(users(:testuser)).size.should eq 0
	end
	it 'it finds 2 open intervals' do
		user = users(:testuser)
		Interval.create!(:start => DateTime.new(2012,7,1), :user=> user)
		Interval.create!(:start => DateTime.now, :user=> user)
		Interval.get_open_intervals(user).size.should eq 2
	end
	it 'it should not save because start is greater than stop' do
		Interval.new(:start => DateTime.new(2012,7,1),:stop=> DateTime.new(2012,6,30), 
			:user=> users(:testuser)).save.should eq false
	end
	it 'it should not find an open interval' do
		Interval.open?(users(:testuser)).should eq false
	end
	it 'it should find an open interval' do
		user = users(:testuser)
		Interval.create!(:start => DateTime.new(2012,7,1), :user=> user)
		Interval.open?(user).should eq true
	end
	it 'access denied because of the false user' do
		user = users(:testuser)
		interval = Interval.new(:start => DateTime.new(2012,7,1), :user=> user)
		interval.access_allowed?(users(:seconduser)).should eq false
	end
	it 'access allowed' do
		user = users(:testuser)
		interval = Interval.new(:start => DateTime.new(2012,7,1), :user=> user)
		interval.access_allowed?(user).should eq true
	end
	it 'diff from an 2 intervals equals 7200 secs' do
		interval1 = Interval.new( :start => DateTime.new(2012,7,17,10,0), 
			:stop => DateTime.new(2012,7,17,11,0))
		interval2 = Interval.new( :start => DateTime.new(2012,7,17,10,0), 
			:stop => DateTime.new(2012,7,17,11,0))
		Interval.sum_diffs([interval1,interval2]).should eq 7200
	end
	it 'diff from an 0 intervals equals 0 secs' do
		Interval.sum_diffs([]).should eq 0
	end
  it 'when working today more than worktime secs overtime will get updated' do
  	user = users(:thriduser)
    start = DateTime.now
    stop = start + (28081/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> user)
    User.find(user.id).overtime.should eq 1
  end
  it 'when changing an interval in the past to less than worktime overtime gets updated' do
  	user = users(:thriduser)
    start = DateTime.new(2012,7,1,8)
    stop = start + (28081/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> user)
    User.find(user.id).overtime.should eq 1
  end
  it 'when working 1 sec more than worktime overtime is 1 sec' do
    start = DateTime.new(2012,7,1,8)
    stop = start + (28081/86400.0)
    interval = Interval.new(:start => start, :stop => stop , :user=> users(:seconduser))
    interval.calculate_new_overtime_for_new_old_interval.should eq -24479
  end
  it 'when changing an interval in the past overtime gets updated' do
    start = DateTime.new(2012,7,1,8)
    stop = start + (28081/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> users(:seconduser))
    User.find(users(:seconduser).id).overtime.should eq -24479
  end
  it 'when changing an interval in the past overtime gets updated' do
  	user = users(:seconduser)
    start = DateTime.new(2012,7,1,8)
    stop = start + (28081/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> user)
    Interval.create!(:start => start, :stop => start + (1/86400.0), :user=> user)
    User.find(users(:seconduser).id).overtime.should eq -24478
  end
  it 'when changing an interval from today overtime gets updated to -1' do
    start = DateTime.now
    stop = start + (24479/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> users(:seconduser))
    User.find(users(:seconduser).id).overtime.should eq -1
  end
  it "when working today more than worktime overtime gets updated (may not work near 0 o'clock)" do
		user = users(:testuser)
    start = DateTime.now
    stop = start + (28080/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> user)
    User.find(user.id).overtime.should eq 1
  end
  it 'when altering an old interval overtime gets updated' do
  	intervals(:one).update_attribute(:stop, DateTime.new(2000,1,1,8) + (28081/86400.0))
  	User.find(users(:testuser).id).overtime.should eq -28078
  end
  it 'when altering an old interval overtime is 7200' do
  	start = DateTime.new(2012,7,1,8)
  	stop = start + (28080/86400.0)
  	interval = Interval.create(:start => start, :stop => stop , :user=> users(:seconduser))
  	interval.stop = stop + (1/86400.0)
  	interval.calculate_new_overtime_for_altered_old_interval.should eq -24479
  end
  it 'User works three in three intervals today' do
		user = users(:testuser)
    start = DateTime.now
    stop = start + (28081/86400.0)
    Interval.create!(:start => start, :stop => stop , :user=> user)
    Interval.create!(:start => start, :stop => start + (1/86400.0) , :user=> user)
    intervals = Interval.all_intervals_from_today(user)
    intervals.each {|interval| interval.start.today?.should eq true }
  end
  it 'User has 2h and 1sec overtime' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (7200/86400.0), :user=> user)
    User.find(user.id).overtime.should be 7200 - 28080
    Interval.create!(:start => start, :stop => start + (28080/86400.0) , :user=> user)
    User.find(user.id).overtime.should be 7200
    Interval.create!(:start => start, :stop => start + (1/86400.0) , :user=> user)
    User.find(user.id).overtime.should eq 7201
  end
  it 'User has 1sec overtime' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28080/86400.0) , :user=> user)
    Interval.create!(:start => start, :stop => start + (1/86400.0) , :user=> user)
    User.find(user.id).overtime.should eq 1
  end
  it 'User has 1sec overtime' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28079/86400.0) , :user=> user)
    User.find(user.id).overtime.should eq -1
    Interval.create!(:start => start, :stop => start + (2/86400.0) , :user=> user)
    User.find(user.id).overtime.should eq 1
  end
  it 'overtime gets updated if user deletes an interval' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28079/86400.0) , :user=> user)
    interval = Interval.create(:start => start, :stop => start + (2/86400.0) , :user=> user)
    interval.destroy
    User.find(user.id).overtime.should eq 0
  end  

  it 'overtime gets updated if user deletes an interval' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28080/86400.0) , :user=> user)
    Interval.create!(:start => start, :stop => start + (1/86400.0) , :user=> user)
    interval = Interval.create(:start => start, :stop => start + (2/86400.0) , :user=> user)
    interval.destroy
    User.find(user.id).overtime.should eq 1
  end
  it 'overtime gets updated if user deletes an interval' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28078/86400.0) , :user=> user)
    interval = Interval.create(:start => start, :stop => start + (2/86400.0) , :user=> user)
    interval.destroy
    User.find(user.id).overtime.should eq -2
  end
  it '0 overtime before + 1 h work makes overtime -24480' do
		user = users(:thriduser)
    start = DateTime.now
    interval = Interval.new(:start => start, :stop => start + (3600/86400.0) , :user=> user)
    interval.calculate_new_overtime_for_today.should eq -24480
  end
  it '-1 overtime before + 1 sec work makes overtime 0' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28079/86400.0) , :user=> user)
    interval = Interval.new(:start => start, :stop => start + (1/86400.0) , :user=> user)
    interval.calculate_new_overtime_for_today.should eq 0
  end
  it '-1 overtime before + 2 sec work makes overtime 1' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28079/86400.0) , :user=> user)
    interval = Interval.new(:start => start, :stop => start + (2/86400.0) , :user=> user)
    interval.calculate_new_overtime_for_today.should eq 1
  end
  it '-1 overtime before + 1 sec work makes overtime 9' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28078/86400.0) , :user=> user)
    Interval.create!(:start => start, :stop => start + (1/86400.0) , :user=> user)
    interval = Interval.new(:start => start, :stop => start + (10/86400.0) , :user=> user)
    interval.calculate_new_overtime_for_today.should eq 9
  end
  it '1 overtime before + 1 sec work makes overtime 2' do
		user = users(:thriduser)
    start = DateTime.now
    Interval.create!(:start => start, :stop => start + (28081/86400.0) , :user=> user)
    interval = Interval.new(:start => start, :stop => start + (1/86400.0) , :user=> user)
    interval.calculate_new_overtime_for_today.should eq 2
  end
end
