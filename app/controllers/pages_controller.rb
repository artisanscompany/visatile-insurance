class PagesController < ApplicationController
  def index
    render inertia: "Home"
  end
end
