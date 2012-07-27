require "spec_helper"

describe IntervalsController do
  describe "routing" do

    it "routes to #index" do
      get("/intervals").should route_to("intervals#index")
    end

    it "routes to #new" do
      get("/intervals/new").should route_to("intervals#new")
    end

    it "routes to #show" do
      get("/intervals/1").should route_to("intervals#show", :id => "1")
    end

    it "routes to #edit" do
      get("/intervals/1/edit").should route_to("intervals#edit", :id => "1")
    end

    it "routes to #create" do
      post("/intervals").should route_to("intervals#create")
    end

    it "routes to #update" do
      put("/intervals/1").should route_to("intervals#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/intervals/1").should route_to("intervals#destroy", :id => "1")
    end

    it "routes to #today" do
      get("/intervals/today").should route_to("intervals#today")
    end

    it "routes to #start" do
      post("/intervals/start").should route_to("intervals#start")
    end

    it "routes to #stop" do
      put("/intervals/stop").should route_to("intervals#stop")
    end

    it "routes to root" do
      get("/").should route_to("intervals#today")
    end
  end
end
