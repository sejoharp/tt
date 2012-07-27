class IntervalsController < ApplicationController
  before_filter :authorize
  # GET /intervals
  # GET /intervals.json
  def index
    @intervals = Interval.all_intervals(current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @intervals }
    end
  end

  # GET /intervals/today
  # GET /intervals/today.json
  def today
    @intervals = Interval.all_intervals_in_range(Date.today..Date.today + 1,current_user)
    @is_working = Interval.open? current_user
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @intervals,is_working: @is_working }
    end
  end

  # GET /intervals/1
  # GET /intervals/1.json
  def show
    @interval = Interval.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @interval }
    end
  end

  # GET /intervals/new
  # GET /intervals/new.json
  def new
    @interval = Interval.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @interval } 
    end
  end

  # POST /intervals
  # POST /intervals.json
  def create
    @interval = Interval.new(params[:interval])
    @interval.user = current_user

    respond_to do |format|
      if @interval.save
        format.html { redirect_to @interval, notice: 'Interval was successfully created.' }
        format.json { render json: @interval, status: :created, location: @interval }
      else
        format.html { render action: "new" }
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /intervals/1/edit
  def edit
    interval = Interval.find(params[:id])
    @interval = access_allowed?(interval) ? interval : nil
  end

  # PUT /intervals/1
  # PUT /intervals/1.json
  def update
    @interval = Interval.find(params[:id])

    respond_to do |format|
      if access_allowed?(@interval) and @interval.update_attributes(params[:interval])
        format.html { redirect_to @interval, notice: 'Interval was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @interval.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /intervals/1
  # DELETE /intervals/1.json
  def destroy
    @interval = Interval.find(params[:id])
    if access_allowed?(@interval)
      @interval.destroy
    end

    respond_to do |format|
      if access_allowed?(@interval)
        format.html { redirect_to intervals_today_url, notice: 'Interval deleted.' }
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
        format.html { redirect_to intervals_today_url, notice: 'started working.' }
        format.json { head :no_content }
      else
        format.html { redirect_to intervals_today_url, notice: 'you are still working.' }
        format.json { head :no_content }
      end
    end
  end

  def stop
    respond_to do |format|
      if Interval.stop_interval(current_user)
        format.html { redirect_to intervals_today_url, notice: 'stopped working.' }
        format.json { head :no_content }
      else
        format.html { redirect_to intervals_today_url, notice: 'you are not working.' }
        format.json { head :no_content }
      end
    end
  end
end
