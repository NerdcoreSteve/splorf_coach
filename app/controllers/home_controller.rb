class HomeController < ApplicationController
  layout false

  def index
    @bucket_items = policy_scope(BucketItem)
  end
end
