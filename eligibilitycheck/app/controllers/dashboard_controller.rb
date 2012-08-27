class DashboardController < ApplicationController

  before_filter :authenticate_user!
  
  # GET /dashboard
  # GET /dashboard.json
  def index
    @patients_total = Patient.where(:extDocId => current_user.extDocId, :consent_status => nil)
    @patients_new = Patient.where(:extDocId => current_user.extDocId, :consent_status => nil, :read_status => nil)
    @patients_old = Patient.where(:extDocId => current_user.extDocId, :consent_status => nil, :read_status => 1)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patients }
    end
  end
end
