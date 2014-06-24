class MockController < ApplicationController
  skip_after_action :verify_authorized

  def new_stuff
  end

  def waiting
  end

  def ready
  end

  def wip
  end

  def done
  end

  def remember
  end

  def people
  end
end
