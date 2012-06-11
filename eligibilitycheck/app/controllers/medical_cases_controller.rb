class MedicalCasesController < ApplicationController

  before_filter :authenticate_user!

  # GET /medical_cases
  # GET /medical_cases.json
  def index
    @medical_cases = MedicalCase.joins(:patient).where('patients.extDocId' => current_user.extDocId).order("medical_cases.created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @medical_cases }
    end
  end

  # GET /medical_cases/1
  # GET /medical_cases/1.json
  def show
    @medical_case = MedicalCase.joins(:patient).where('patients.extDocId' => current_user.extDocId).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @medical_case }
    end
  end
end
