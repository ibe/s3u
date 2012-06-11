class DiagnosesController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /diagnoses
  # GET /diagnoses.json
  def index
    @diagnoses = Diagnosis.order("created_at DESC")

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
end
