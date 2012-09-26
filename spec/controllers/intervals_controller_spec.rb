require 'spec_helper'

describe IntervalsController do
  fixtures :users, :intervals

  def valid_attributes
    {:start => DateTime.now}
  end

  def valid_session
    {:user_id =>users(:testuser).id}
  end

  describe "GET index" do
    it "assigns all intervals as @intervals" do
      get :index, {}, valid_session
      assigns(:intervals).should eq([intervals(:one),intervals(:two),intervals(:three)])
    end
  end

  describe "GET today" do
    it "displays one interval (may not work near 0 o'clock)" do
      get :today, {}, valid_session
      assigns(:intervals).should eq([intervals(:three)])
    end
    it "testuser does not work right now" do
      get :today, {}, valid_session
      assigns(:is_working).should eq false
    end
    it "testuser works right now" do
      post :start, {}, valid_session
      get :today, {}, valid_session
      assigns(:is_working).should eq true
    end
    it "testuser has to work 28080 secs per day" do
      get :today, {}, valid_session
      assigns(:worktime).should eq 28080
    end
    it "testuser has -28079 secs overtime" do
      get :today, {}, valid_session
      assigns(:overtime).should eq -28079
    end
    it "testuser worked 3601 secs" do
      get :today, {}, valid_session
      assigns(:worked_time).should eq 1
    end
    it "testuser worked in two intervals" do
      get :today, {}, valid_session
      assigns(:intervals).size.should eq 1
    end
    it "testuser has to work 28079 secs without overtime" do
      get :today, {}, valid_session
      assigns(:time_to_work_without_overtime).should eq 28079
    end
    it "testuser can finish in 28080 secs (does not work every time)" do
      get :today, {}, {:user_id =>users(:thriduser).id}
      current_user = assigns(:current_user)
      finishing_time_expected = DateTime.now + (current_user.worktime/86400.0) + (current_user.overtime/86400.0)
      assigns(:finishing_time).year.should eq finishing_time_expected.year
      assigns(:finishing_time).month.should eq finishing_time_expected.month
      assigns(:finishing_time).day.should eq finishing_time_expected.day
      assigns(:finishing_time).hour.should eq finishing_time_expected.hour
      assigns(:finishing_time).min.should eq finishing_time_expected.min
    end
    it "thriduser worked 1 h too much so there is 1 h overtime" do
      user = users(:thriduser)
      start = DateTime.new(2012,7,1,8,0)
      stop = DateTime.new(2012,7,1,16,48)
      Interval.create!(:start => start, :stop =>stop,:user=> user)
      post :start, {}, {:user_id =>users(:thriduser).id}
      get :today, {}, {:user_id =>users(:thriduser).id}
      assigns(:overtime).should eq 3600
    end
    it "thriduser worked 1 h too much so there is 0 h overtime because of negative previous overtime" do
      user = users(:thriduser)
      user.overtime = -3600
      user.save
      start = DateTime.new(2012,7,1,8,0)
      stop = DateTime.new(2012,7,1,16,48)
      Interval.create!(:start => start, :stop =>stop,:user=> user)
      post :start, {}, {:user_id =>users(:thriduser).id}
      get :today, {}, {:user_id =>users(:thriduser).id}
      assigns(:overtime).should eq 0
    end
  end

  describe "GET show" do
    it "assigns the requested interval as @interval" do
      get :show, {:id => intervals(:one).to_param}, valid_session
      assigns(:interval).should eq(intervals(:one))
    end
    it "redirect to today because interval is from an other user" do
      get :show, {:id => intervals(:four).to_param}, valid_session
      response.should redirect_to today_intervals_url
    end
    it "returns an error message because interval is from an other user" do
      get :show, {:id => intervals(:four).to_param}, valid_session
      flash[:alert].should eq 'showing this interval is not allowed'
    end
  end

  describe "PUT stop" do
    it "fills the latest open interval with a stop dateteime" do
      Interval.start_interval(users(:testuser))
      Interval.where(:user_id => users(:testuser).id).last.stop.should be nil
      put :stop, {}, valid_session
      Interval.where(:user_id => users(:testuser).id).last.stop.should_not be nil
    end
    it "does not do anything because all intervals are closed" do
      expect {
        put :stop, {}, valid_session
      }.to change(Interval, :count).by(0)
    end
    it 'should redirect to intervals today' do
      put :stop, {}, valid_session
      response.should redirect_to(today_intervals_url)
    end
    it "returns a confirmation notice" do
      Interval.start_interval(users(:testuser))
      put :stop, {}, valid_session
      flash[:notice].should eq 'stopped working.'
    end
    it "returns a error notice, because user is not working" do
      put :stop, {}, valid_session
      flash[:notice].should eq 'you are not working.'
    end
  end

  describe "POST start" do
    it "creates a new interval which starts now" do
      expect {
        post :start, {}, valid_session
      }.to change(Interval, :count).by(1)
    end
    it "does not create a new interval due to an open interval" do
      Interval.start_interval(users(:testuser))
      expect {
        post :start, {}, valid_session
      }.to change(Interval, :count).by(0)
    end
    it 'should redirect to intervals index' do
      post :start, {}, valid_session
      response.should redirect_to(today_intervals_url)
    end
    it "returns a confirmation notice" do
      post :start, {}, valid_session
      flash[:notice].should eq 'started working.'
    end
    it "returns a error notice, because user is already working" do
      post :start, {}, valid_session
      post :start, {}, valid_session
      flash[:notice].should eq 'you are already working.'
    end
    it "returns a error notice, because user is not logged in" do
      post :start, {}
      flash[:alert].should eq 'Not authenticated'
    end
    it "redirects to login page, because user is not logged in" do
      post :start, {}
      response.should redirect_to(login_url)
    end
  end

  describe "GET new" do
    it "assigns a new interval as @interval" do
      get :new, {}, valid_session
      assigns(:interval).should be_a_new(Interval)
    end
  end

  describe "GET edit" do
    it "assigns the requested interval as @interval" do
      get :edit, {:id => intervals(:one).to_param}, valid_session
      assigns(:interval).should eq(intervals(:one))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Interval" do
        expect {
          post :create, {:interval => valid_attributes}, valid_session
        }.to change(Interval, :count).by(1)
      end

      it "assigns a newly created interval as @interval" do
        post :create, {:interval => valid_attributes}, valid_session
        assigns(:interval).should be_a(Interval)
        assigns(:interval).should be_persisted
      end

      it "redirects to the created interval" do
        post :create, {:interval => valid_attributes}, valid_session
        response.should redirect_to(Interval.last)
      end

      it "returns a notice" do
        post :create, {:interval => valid_attributes}, valid_session
        flash[:notice].should eq 'Interval was successfully created.'
      end
      
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved interval as @interval" do
        # Trigger the behavior that occurs when invalid params are submitted
        Interval.any_instance.stub(:save).and_return(false)
        post :create, {:interval => {}}, valid_session
        assigns(:interval).should be_a_new(Interval)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Interval.any_instance.stub(:save).and_return(false)
        post :create, {:interval => {}}, valid_session
        response.should render_template("new")
      end
      it "redirects to login page, because user is not logged in" do
        post :create, {:interval => {}}
        response.should redirect_to(login_url)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested interval" do
        # Assuming there are no other intervals in the database, this
        # specifies that the Interval created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Interval.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => intervals(:one).to_param, :interval => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested interval as @interval" do
        put :update, {:id => intervals(:one).to_param, :interval => valid_attributes}, valid_session
        assigns(:interval).should eq(intervals(:one))
      end

      it "redirects to the interval" do
        put :update, {:id => intervals(:one).to_param, :interval => {:stop => DateTime.now}}, valid_session
        response.should redirect_to(intervals(:one))
      end
      it "returns a notice" do
        put :update, {:id => intervals(:one).to_param, :interval => {:stop => DateTime.now}}, valid_session
        flash[:notice].should eq 'Interval was successfully updated.'
      end
      
    end

    describe "with invalid params" do
      it "assigns the interval as @interval" do
        # Trigger the behavior that occurs when invalid params are submitted
        Interval.any_instance.stub(:save).and_return(false)
        put :update, {:id => intervals(:one).to_param, :interval => {}}, valid_session
        assigns(:interval).should eq(intervals(:one))
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Interval.any_instance.stub(:save).and_return(false)
        put :update, {:id => intervals(:one).to_param, :interval => {}}, valid_session
        response.should render_template("edit")
      end
      it "returns no message because user is not allowed to access" do
        put :update, {:id => intervals(:four).to_param, :interval => valid_attributes}, valid_session
        flash[:notice].should_not eq 'Interval was successfully updated.'
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested interval" do
      expect {
        delete :destroy, {:id => intervals(:one).to_param}, valid_session
      }.to change(Interval, :count).by(-1)
    end

    it "redirects to the intervals list" do
      delete :destroy, {:id => intervals(:one).to_param}, valid_session
      response.should redirect_to(today_intervals_url)
    end

    it "returns a notice" do
      delete :destroy, {:id => intervals(:one).to_param}, valid_session
      flash[:notice].should eq 'Interval deleted.'
    end

    it "returns a error message because user is not allowed to access" do
      delete :destroy, {:id => intervals(:four).to_param}, valid_session
      flash[:alert].should eq 'deleting interval denied.'
    end

    it "redirects to index because user is not allowed to access" do
      delete :destroy, {:id => intervals(:four).to_param}, valid_session
      response.should redirect_to(intervals_url)
    end
  end

end
