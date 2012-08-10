class MedicalCasesController < ApplicationController

  before_filter :authenticate_user!

  helper_method :sort_column, :sort_direction

  # GET /medical_cases
  # GET /medical_cases.json
  def index
    @medical_cases = MedicalCase.joins(:patient).where('patients.extDocId' => current_user.extDocId).order(sort_column + ' ' + sort_direction).page params[:page]

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

  private
  
  def sort_column
    MedicalCase.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
