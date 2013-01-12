class Interval < ActiveRecord::Base
  belongs_to :user
  attr_accessible :start, :stop, :user
  validates_presence_of :user
  validates_presence_of :start
  validate :stop_has_to_be_greater_than_or_equal_to_start, :if => 'not stop.nil?'
  before_save :update_overtime
  after_destroy :set_overtime

  def self.all_intervals_in_past(user)
    start_date = Interval.all_intervals(user).first.start
    end_date = Date.today
    Interval.all_intervals_in_range(start_date..end_date, user)
  end

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

  def user_ever_worked?
    Interval.where(:user_id=>self.user).count > 0
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

  def overtime_update?
    self.valid? and self.user_ever_worked?
  end

  def update_overtime
    if self.overtime_update?
      if self.stop.nil? and self.first_interval_on_new_day?
        Interval.save_new_overtime(self.user)
      end
    end
  end

  def set_overtime
    Interval.save_new_overtime(self.user)
  end

  def self.save_new_overtime(user)
    if Interval.where(:user_id=>user).count > 0
      user.overtime = Interval.recalculate_overtime(user)
      user.save
    end
  end

  def self.recalculate_overtime(user)
    intervals = Interval.all_intervals_in_past(user)
    if not intervals.empty?
      day_count = 1
      start = intervals.first.start.to_date
      intervals.each do |interval|
        if interval.start.to_date != start
          day_count += 1
          start = interval.start.to_date
        end
      end
      Interval.sum_diffs(intervals) - user.worktime * day_count
    else
      0
    end
  end
end
