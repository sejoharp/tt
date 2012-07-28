require 'spec_helper'

describe Interval do
	fixtures :users, :intervals
	it 'save fails with empty interval' do
	  	interval = Interval.new
	  	interval.save.should eq false
	end
	it 'save fails with empty start' do
	  	interval = Interval.new
	  	interval.user = User.new(:name=>'user', :password=>'pw')
	  	interval.save.should eq false
	end
	it 'saved successfully' do
	  	interval = Interval.new
	  	interval.start = DateTime.now
	  	interval.stop = DateTime.now
	  	interval.user = User.new(:name=>'user', :password=>'pw')
	  	interval.save.should eq true
	end	
	it 'saved successfully with minimal data' do
	  	interval = Interval.new
	  	interval.start = DateTime.now
	  	interval.user = User.new(:name=>'user', :password=>'pw')
	  	interval.save.should eq true
	end
	it 'all intervals from one day' do
		user = User.new(:name=>'user', :password=>'pw')
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
		it 'all intervals from today' do
		 intervals = Interval.all_intervals_in_range Date.today..(Date.today + 1),users(:testuser)
		 intervals.should eq([intervals(:three)])
	end
	it 'all_intervals_in_range return empty array if no data is available' do
		range = Date.new(2012,7,2)..Date.new(2012,7,3)
		user = User.new(:name=>'user', :password=>'pw')
		intervals = Interval.all_intervals_in_range(range,user).size.should eq 0
	end
	it 'start new successfully' do
		Interval.start_interval(users(:seconduser))
		Interval.all_intervals(users(:seconduser)).size.should eq 2
	end
	it 'diff from an interval equals 3600 secs' do
		interval = Interval.new( :start => DateTime.new(2012,7,17,10,0), :stop => DateTime.new(2012,7,17,11,0))
		interval.diff.should eq 3600
	end
	it 'diff without stop calcuates diff till now' do
		interval = Interval.new( :start => DateTime.new(2012,7,15,10,0))
		interval.diff.should be > 0
	end
	it 'all_intervals delivers 2 entries' do
		user = User.new(:name=>'user', :password=>'pw')
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
		Interval.new(:start => DateTime.new(2012,7,1),:stop=> DateTime.new(2012,6,30), :user=> users(:testuser)).save.should eq false
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
		interval = Interval.create(:start => DateTime.new(2012,7,1), :user=> user)
		interval.access_allowed?(users(:seconduser)).should eq false
	end
	it 'access allowed' do
		user = User.create(:name=>'user', :password=>'pw')
		interval = Interval.create(:start => DateTime.new(2012,7,1), :user=> user)
		interval.access_allowed?(user).should eq true
	end
end
