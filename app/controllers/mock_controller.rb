class MockController < ApplicationController
  skip_after_action :verify_authorized
  skip_before_filter :verify_authenticity_token
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
    @bucket_items = {'New Stuff' => [{type: :Thing,
                                      description: 'Finish bucket list ajax call',
                                      notes: 'no real notes for this one'},
                                     {type: :Thing,
                                      description: 'Go grocery shopping',
                                      notes: 'I should really go do that now.'}],
                     'Waiting'  => [{type: :Habit,
                                      description: 'Keep house clean',
                                      notes: 'waiting on getting the house clean'},
                                     {type: :Thing,
                                      description: 'Make android version of this app',
                                      notes: 'Waiting on learning lisp, then scala'}]}
    respond_to do |format|
      format.json { render json: @bucket_items[params[:bucket]] }
    end
  end

end
