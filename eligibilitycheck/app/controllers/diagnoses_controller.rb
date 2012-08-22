class DiagnosesController < ApplicationController
  
  before_filter :authenticate_user!
  
  helper_method :sort_column, :sort_direction

  # GET /diagnoses
  # GET /diagnoses.json
  def index
    @diagnoses = Diagnosis.order(sort_column + ' ' + sort_direction).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @diagnoses }
    end
  end

  # GET /diagnoses/1
  # GET /diagnoses/1.json
  def show
    @diagnosis = Diagnosis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @diagnosis }
    end
  end

  private
  
  def sort_column
    Diagnosis.column_names.include?(params[:sort]) ? params[:sort] : "icd10Code"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
