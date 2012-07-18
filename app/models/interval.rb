class Interval < ActiveRecord::Base
  belongs_to :user
  attr_accessible :start, :stop, :user
  validates_presence_of :user
  validates_presence_of :start

  def self.all_intervals_in_range(range,user)
  	Interval.where(:start => range, :user_id=>user).order(:start)
  end

  def self.all_intervals(user)
  	Interval.where(:user_id=>user).order(:start)
  end

  def self.start_interval(user)
  	Interval.new(:start => DateTime.now, :user=>user).save
  end

  def diff
  	if stop
  		stop.to_f - start.to_f
  	else
  		DateTime.now.to_f - start.to_f
  	end
  end
end
