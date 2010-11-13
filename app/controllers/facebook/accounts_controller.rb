class Facebook::AccountsController < ApplicationController

  def show
    @person = Person.find(params[:person_id])
    if @logged_in.can_edit?(@person)
      # TODO
    else
      render :text => I18n.t('not_authorized'), :layout => true, :status => 401
    end
  end

end
