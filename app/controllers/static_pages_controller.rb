class StaticPagesController < ApplicationController
  skip_after_action :verify_authorized

  def home
  end

  def help
  end

  def contact
  end
end
