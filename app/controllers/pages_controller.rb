class PagesController < ApplicationController
  before_action :skip_authorization, only: [:home]

  def home; end
end
