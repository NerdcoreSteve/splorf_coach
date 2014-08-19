class HomeController < ApplicationController
  def index
    @bucket_items = policy_scope(BucketItem)
  end
end
