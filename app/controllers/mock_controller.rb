class MockController < ApplicationController
  skip_after_action :verify_authorized
  layout false

  def home
  end

end
