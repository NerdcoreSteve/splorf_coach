class MockController < ApplicationController
  skip_after_action :verify_authorized
  skip_before_filter :verify_authenticity_token
  layout false

  def home
  end

  def buckets
    @buckets = ['New Stuff', 'Waiting', 'Ready', 'WIP', 'Done', 'Reference', 'People']
    respond_to do |format|
      format.json { render json: @buckets }
    end
  end

  #TODO do I eventually want to have html and json actions both of which use
  #TODO some helper to get the hash of bucket items?
  def bucket_items
    @bucket_items = {'New Stuff'  => [{type: :Thing,
                                       description: 'Finish bucket list ajax call',
                                       notes: 'no real notes for this one'},
                                      {type: :Thing,
                                       description: 'Go grocery shopping',
                                       notes: 'I should really go do that now.'},
                                      {type: :Thing,
                                       description: 'Learn to sew',
                                       notes: 'Not for a while I think.'}],
                     'Waiting'    => [{type: :Habit,
                                       description: 'Keep house clean',
                                       notes: 'waiting on getting the house clean'},
                                      {type: :Thing,
                                       description: 'Make android version of this app',
                                       notes: 'Waiting on learning lisp, then scala'}],
                     'Ready'      => [{type: :Thing,
                                       description: 'Finish Splorf coach',
                                       notes: 'Can I ever really call it finished?'},
                                      {type: :Thing,
                                       description: 'learn lisp',
                                       notes: 'Lisp is fun!'}],
                     'WIP'        => [{type: :Thing,
                                       description: 'Get app in a usable state asap',
                                       notes: 'No need to make it fancy or add all the features you need '},
                                      {type: :Thing,
                                       description: 'learn vim',
                                       notes: 'vim is awesome'}],
                     'Done'       => [{type: :Thing,
                                       description: 'Nothing!',
                                       notes: 'You\'ve finished nothing!!!'}],
                     'Reference'  => [{type: :Habit,
                                       description: 'Very important information',
                                       notes: 'Maybe put links here'}],
                     'People'     => [{type: :Person,
                                       first_name: 'Bob',
                                       last_name: 'Saget',
                                       notes: 'Man, I used to watch full house. So embarrasing...'},
                                       {type: :Person,
                                       first_name: 'Bat',
                                       last_name: 'Man',
                                       notes: 'The caped crusader'}]}
    respond_to do |format|
      format.json { render json: @bucket_items[params[:bucket]] }
    end
  end

end
