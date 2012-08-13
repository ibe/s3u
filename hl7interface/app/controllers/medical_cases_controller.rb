class MedicalCasesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  helper_method :sort_column, :sort_direction

  # GET /medical_cases
  # GET /medical_cases.json
  def index
    @medical_cases = MedicalCase.order(sort_column + ' ' + sort_direction).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @medical_cases }
    end
  end

  # GET /medical_cases/1
  # GET /medical_cases/1.json
  def show
    @medical_case = MedicalCase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @medical_case }
    end
  end

  ## GET /medical_cases/new
  ## GET /medical_cases/new.json
  #def new
  #  @medical_case = MedicalCase.new
  #
  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.json { render :json => @medical_case }
  #  end
  #end
  #
  ## GET /medical_cases/1/edit
  #def edit
  #  @medical_case = MedicalCase.find(params[:id])
  #end
  #
  ## POST /medical_cases
  ## POST /medical_cases.json
  #def create
  #  @medical_case = MedicalCase.new(params[:medical_case])
  #
  #  respond_to do |format|
  #    if @medical_case.save
  #      format.html { redirect_to @medical_case, :notice => 'Medical case was successfully created.' }
  #      format.json { render :json => @medical_case, :status => :created, :location => @medical_case }
  #    else
  #      format.html { render :action => "new" }
  #      format.json { render :json => @medical_case.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end
  #
  ## PUT /medical_cases/1
  ## PUT /medical_cases/1.json
  #def update
  #  @medical_case = MedicalCase.find(params[:id])
  #
  #  respond_to do |format|
  #    if @medical_case.update_attributes(params[:medical_case])
  #      format.html { redirect_to @medical_case, :notice => 'Medical case was successfully updated.' }
  #      format.json { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.json { render :json => @medical_case.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end
  #
  ## DELETE /medical_cases/1
  ## DELETE /medical_cases/1.json
  #def destroy
  #  @medical_case = MedicalCase.find(params[:id])
  #  @medical_case.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to medical_cases_url }
  #    format.json { head :ok }
  #  end
  #end

  private
  
  def sort_column
    MedicalCase.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
