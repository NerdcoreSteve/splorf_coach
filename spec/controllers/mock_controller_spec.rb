require 'spec_helper'

describe MockController do

  describe "GET 'new_stuff'" do
    it "returns http success" do
      get 'new_stuff'
      response.should be_success
    end
  end

  describe "GET 'waiting'" do
    it "returns http success" do
      get 'waiting'
      response.should be_success
    end
  end

  describe "GET 'ready'" do
    it "returns http success" do
      get 'ready'
      response.should be_success
    end
  end

  describe "GET 'wip'" do
    it "returns http success" do
      get 'wip'
      response.should be_success
    end
  end

  describe "GET 'done'" do
    it "returns http success" do
      get 'done'
      response.should be_success
    end
  end

  describe "GET 'remember'" do
    it "returns http success" do
      get 'remember'
      response.should be_success
    end
  end

  describe "GET 'people'" do
    it "returns http success" do
      get 'people'
      response.should be_success
    end
  end

end
