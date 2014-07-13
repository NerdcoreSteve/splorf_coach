class MockController < ApplicationController
  skip_after_action :verify_authorized
  layout false

  def home
  end

  def buckets
    @buckets = ['New Stuff', 'Waiting', 'Ready', 'Wip', 'Done', 'Reference', 'People']
    respond_to do |format|
      format.json { render json: @buckets }
    end
  end

end
