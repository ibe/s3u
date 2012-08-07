class DashboardController < ApplicationController

  before_filter :authenticate_user!
  
  # GET /dashboard
  # GET /dashboard.json
  def index
    @total_patients = Patient.where("extDocId = ? AND consent_status IS NULL", current_user.extDocId)
    @new_patients = @total_patients.where("created_at > ?", current_user.current_sign_in_at.in_time_zone('Berlin'))
    @remaining_patients = @total_patients.count - @new_patients.count

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patients }
    end
  end
end
