class IntervalsController < ApplicationController
  before_filter :authenticate

  def index
    @intervals = Interval.all_intervals current_user

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @intervals }
    end
  end

  def recalculate_overtime
    Interval.save_new_overtime(current_user)
    respond_to do |format|
        format.html { redirect_to user_path(current_user), notice: 'overtime calculated'}
        format.json { head :no_content }
    end
  end

  def today
    @intervals = Interval.all_intervals_from_today current_user
    @is_working = Interval.open? current_user
    @worktime = current_user.worktime
    @overtime = current_user.overtime
    @worked_time = Interval.sum_diffs @intervals
    @time_to_work = @worktime - @worked_time - @overtime
    @time_to_work_without_overtime = @worktime - @worked_time
    @finishing_time = DateTime.now + (@time_to_work/86400.0)
    @finishing_time_without_overtime = DateTime.now + (@time_to_work_without_overtime/86400.0)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @intervals,is_working: @is_working }
    end
  end

  def show
    @interval = Interval.find(params[:id])

    respond_to do |format|
      if @interval.access_allowed? current_user
        format.html # show.html.erb
        format.json { render json: @interval }
      else
        format.html { redirect_to today_intervals_url, alert: 'showing this interval is not allowed'}
        format.json { head :no_content }        
      end
    end
  end

  def new
    @interval = Interval.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interval } 
    end
  end

  def create
    @interval = Interval.new(params[:interval])
    @interval.user = current_user

    respond_to do |format|
      if @interval.save
        refresh_overtime if not @interval.stop.nil?
        format.html { redirect_to @interval, notice: 'Interval was successfully created.' }
        format.json { render json: @interval, status: :created, location: @interval }
      else
        format.html { render action: "new" }
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    interval = Interval.find(params[:id])
    @interval = interval.access_allowed?(current_user) ? interval : nil
  end

  def update
    @interval = Interval.find(params[:id])

    respond_to do |format|
      if @interval.access_allowed?(current_user) and @interval.update_attributes(params[:interval])
        refresh_overtime if not @interval.stop.nil?
        format.html { redirect_to @interval, notice: 'Interval was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit"}
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @interval = Interval.find(params[:id])
    if @interval.access_allowed?(current_user)
      @interval.destroy
    end

    respond_to do |format|
      if @interval.access_allowed?(current_user)
        format.html { redirect_to today_intervals_url, notice: 'Interval deleted.' }
        format.json { head :no_content }
      else
        format.html { redirect_to intervals_url, alert: "deleting interval denied." }
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  def start
    respond_to do |format|
      if not Interval.open?(current_user) and Interval.start_interval(current_user)
        format.html { redirect_to today_intervals_url, notice: 'started working.' }
        format.json { head :no_content }
      else
        format.html { redirect_to today_intervals_url, notice: 'you are already working.' }
        format.json { head :no_content }
      end
    end
  end

  def stop
    respond_to do |format|
      if Interval.stop_interval(current_user)
        format.html { redirect_to today_intervals_url, notice: 'stopped working.' }
        format.json { head :no_content }
      else
        format.html { redirect_to today_intervals_url, notice: 'you are not working.' }
        format.json { head :no_content }
      end
    end
  end

  def refresh_overtime
    @current_user.overtime = User.find(@current_user).overtime
  end
end
