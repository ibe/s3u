class CriteriaController < ApplicationController
  ## GET /criteria
  ## GET /criteria.json
  #def index
  #  @criteria = Criterion.all
  #
  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.json { render :json => @criteria }
  #  end
  #end
  #
  ## GET /criteria/1
  ## GET /criteria/1.json
  #def show
  #  @criterion = Criterion.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.json { render :json => @criterion }
  #  end
  #end
  #
  ## GET /criteria/new
  ## GET /criteria/new.json
  #def new
  #  @criterion = Criterion.new
  #
  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.json { render :json => @criterion }
  #  end
  #end
  #
  ## GET /criteria/1/edit
  #def edit
  #  @criterion = Criterion.find(params[:id])
  #end

  # POST /criteria
  # POST /criteria.json
  def create
    @trial = Trial.find(params[:trial_id])
    @criterion = @trial.criteria.create(params[:criterion])
    redirect_to trial_path(@trial)
  end

  ## PUT /criteria/1
  ## PUT /criteria/1.json
  #def update
  #  @criterion = Criterion.find(params[:id])
  #
  #  respond_to do |format|
  #    if @criterion.update_attributes(params[:criterion])
  #      format.html { redirect_to @criterion, :notice => 'Criterion was successfully updated.' }
  #      format.json { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.json { render :json => @criterion.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /criteria/1
  # DELETE /criteria/1.json
  def destroy
    @trial = Trial.find(params[:trial_id])
    @criterion = @trial.criteria.find(params[:id])
    @criterion.destroy
    redirect_to trial_path(@trial)
  end
end
