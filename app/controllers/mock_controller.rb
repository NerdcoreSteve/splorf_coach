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

  def bucket_items
    @bucket_items = [{type: :Thing,
                      description: 'Finish bucket list ajax call',
                      notes: 'no real notes for this one'},
                     {type: :Thing,
                      description: 'Go grocery shopping',
                      notes: 'I should really go do that now.'}]
    respond_to do |format|
      format.json { render json: @bucket_items }
    end
  end

end
