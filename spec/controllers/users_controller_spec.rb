require 'spec_helper'
describe UsersController do
	fixtures :users, :intervals

  def valid_session
    {:user_id =>users(:testuser).id}
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end
  describe "GET 'edit'" do
  	it "redirect to login because testuser has no permission to edit seconduser" do
      get :edit, {:id => users(:seconduser).to_param}, valid_session
      response.should redirect_to(login_url)
    end
  end

end
