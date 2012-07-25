require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe IntervalsController do
  fixtures :users, :intervals
  # This should return the minimal set of attributes required to create a valid
  # Interval. As you add validations to Interval, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:start => DateTime.now}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # IntervalsController. Be sure to keep this updated too.
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
    it "should display one interval" do
      get :today, {}, valid_session
      assigns(:intervals).should eq([intervals(:three)])
    end
    it "testuser should not work right now" do
      get :today, {}, valid_session
      assigns(:is_working).should eq false
    end
    it "testuser should work right now" do
      post :start, {}, valid_session
      get :today, {}, valid_session
      assigns(:is_working).should eq true
    end
  end

  describe "GET show" do
    it "assigns the requested interval as @interval" do
      get :show, {:id => intervals(:one).to_param}, valid_session
      assigns(:interval).should eq(intervals(:one))
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
      response.should redirect_to(intervals_today_url)
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
      response.should redirect_to(intervals_today_url)
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
      response.should redirect_to(intervals_url)
    end
  end

end
