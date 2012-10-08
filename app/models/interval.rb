class Interval < ActiveRecord::Base
  belongs_to :user
  attr_accessible :start, :stop, :user
  validates_presence_of :user
  validates_presence_of :start
  validate :stop_has_to_be_greater_than_or_equal_to_start, :if => 'not stop.nil?'
  before_save :update_overtime
  after_destroy :set_overtime_after_destroy

  def self.all_intervals_in_range(range,user)
    Interval.where(:start => range, :user_id=>user).order(:start)
  end

  def self.all_intervals_from_today(user)
    Interval.all_intervals_in_range(Date.today..Date.today + 1,user)
  end

  def self.one_interval_today?(user)
    Interval.all_intervals_in_range(Date.today..Date.today + 1,user).count == 1
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

  def calculate_new_overtime_for_altered_old_interval
      intervals = Interval.all_intervals_in_range(self.start..self.start + 1, self.user)
      interval_old = Interval.find(self.id)
      worktime_old = Interval.sum_diffs(intervals)
      worktime_new = worktime_old - interval_old.diff + self.diff
      worktime_diff = worktime_new - worktime_old
      self.user.overtime + worktime_diff
  end

  def calculate_new_overtime_for_new_old_interval
    intervals = Interval.all_intervals_in_range(self.start..self.start + 1, self.user)
    if intervals.empty?
      self.diff - self.user.worktime + self.user.overtime
    else
      self.diff + self.user.overtime
    end
  end

  def set_overtime_after_destroy
    if not self.start.today? and not self.stop.nil?
      self.user.overtime -= self.diff
      self.user.save
    end
  end

  def user_ever_worked?
    value = Interval.where(:user_id=>self.user).count > 0
    value
  end

  def self.get_last_day_from_user(user)
    Interval.where(:user_id=>user).last.start.to_date
  end

  def first_interval_on_new_day?
      Interval.get_last_day_from_user(self.user).today? == false
  end

  def self.get_intervals_from_last_day(user)
    last_day = Interval.get_last_day_from_user(user)
    Interval.all_intervals_in_range(last_day..last_day + 1,user)
  end

  def set_overtime_before_update
      if self.id
        self.user.overtime = self.calculate_new_overtime_for_altered_old_interval
      else
        self.user.overtime = self.calculate_new_overtime_for_new_old_interval
      end
      self.user.save
  end

  def set_new_overtime_for_last_day
      intervals_from_last_day = Interval.get_intervals_from_last_day(self.user)
      worked_time = Interval.sum_diffs intervals_from_last_day
      self.user.overtime = worked_time + self.user.overtime - self.user.worktime
      self.user.save
  end

  def overtime_update?
    self.valid? and self.user_ever_worked?
  end

  def update_overtime
    if self.overtime_update?
      if self.stop.nil? and self.first_interval_on_new_day?
        self.set_new_overtime_for_last_day
      elsif not self.stop.nil? and not self.start.today?
        self.set_overtime_before_update
      end
    end
  end
end