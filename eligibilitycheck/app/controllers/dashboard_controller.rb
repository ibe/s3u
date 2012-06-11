class DashboardController < ApplicationController

  before_filter :authenticate_user!
  
  # GET /dashboard
  # GET /dashboard.json
  def index
    @total_patients = Patient.where(:extDocId => current_user.extDocId)
    @new_patients = @total_patients.where("created_at > ?", current_user.last_sign_in_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patients }
    end
  end
end
