class Interval < ActiveRecord::Base
  belongs_to :user
  attr_accessible :start, :stop, :user
  validates_presence_of :user
  validates_presence_of :start
  validate :stop_has_to_be_greater_than_or_equal_to_start, :if => 'not stop.nil?'
  before_save :set_overtime_before_update, :if => 'not stop.nil?'
  after_destroy :set_overtime_after_destroy, :if => 'not stop.nil?'

  def self.all_intervals_in_range(range,user)
  	Interval.where(:start => range, :user_id=>user).order(:start)
  end

  def self.all_intervals_from_today(user)
    Interval.all_intervals_in_range(Date.today..Date.today + 1,user)
  end

  def self.all_intervals(user)
  	Interval.where(:user_id=>user).order(:start)
  end

  def self.start_interval(user)
    if not open?(user)
      Interval.new(:start => DateTime.now, :user=>user).save
    else
      false
    end
  end

  def self.stop_interval(user)
    open_interval = Interval.get_open_intervals(user).last
    if open_interval
      open_interval.stop = DateTime.now
      open_interval.save
    else
      false
    end
  end

  def self.get_open_intervals(user)
    Interval.where(:user_id=>user, :stop=>nil).order(:start)
  end

  def self.open?(user)
    Interval.where(:user_id=>user, :stop=>nil).count > 0
  end

  def diff
  	if stop
  		stop.to_f - start.to_f
  	else
  		DateTime.now.to_f - start.to_f
  	end
  end

  def access_allowed?(user)
    self.user == user
  end

  def stop_has_to_be_greater_than_or_equal_to_start
    if stop and stop.to_f < start.to_f
      errors.add(:stop, "has to be greater or equal to start")
    end
  end

  def self.sum_diffs(intervals)
    sum = 0
    intervals.each {|interval| sum += interval.diff }
    sum
  end

  def calculate_offset_for_altered_old_interval
      old_overtime = Interval.find(self.id).diff - self.user.worktime
      new_overtime = self.diff - self.user.worktime
      new_overtime - old_overtime
  end

  def calculate_offset_for_new_old_interval
    intervals = Interval.all_intervals_in_range(self.start..self.start + 1, self.user)
    worked_time = Interval.sum_diffs(intervals) + self.diff
    if worked_time > self.user.worktime
      total_overtime_today = worked_time - self.user.worktime
      if total_overtime_today > self.diff
        self.diff - self.user.worktime
      else
        total_overtime_today
      end
    else
      0
    end
  end

  def calculate_offset_for_today
    intervals = Interval.all_intervals_from_today(self.user)
    intervals.push(self)
    worked_time = Interval.sum_diffs(intervals)
    overtime = worked_time - self.user.worktime
    if worked_time > self.user.worktime and overtime >= self.diff
      self.diff
    elsif worked_time > self.user.worktime and overtime < self.diff
      overtime
    else
      0
    end
  end

  def set_overtime_before_update
    if self.start.today?
      self.user.overtime += self.calculate_offset_for_today
    elsif self.id
      self.user.overtime += self.calculate_offset_for_altered_old_interval
    else
      self.user.overtime += self.calculate_offset_for_new_old_interval
    end
    self.user.save
  end
  def set_overtime_after_destroy
  end
end
