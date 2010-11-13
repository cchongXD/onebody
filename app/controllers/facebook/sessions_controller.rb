class Facebook::SessionsController < ApplicationController

  def create
    if @logged_in
      if params[:facebook_id] != @logged_in.facebook_id
        @logged_in.facebook_id = params[:facebook_id]
        @logged_in.save
        # render create.js.erb
      elsif !@logged_in.facebook_imported?
        # render create.js.erb
      else
        render :nothing => true
      end
    else
      render :text => I18n.t('not_authorized'), :status => 401
    end
  end

end
