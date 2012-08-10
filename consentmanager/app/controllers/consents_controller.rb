class ConsentsController < ApplicationController

  helper_method :sort_column, :sort_direction

  # GET /consents
  # GET /consents.json
  def index
    @consents = Consent.order(sort_column + ' ' + sort_direction).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @consents }
    end
  end

  # GET /consents/1
  # GET /consents/1.json
  def show
    @consent = Consent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @consent }
    end
  end

  # GET /consents/new
  # GET /consents/new.json
  def new
    @consent = Consent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @consent }
    end
  end

  # GET /consents/1/edit
  def edit
    @consent = Consent.find(params[:id])
  end

  # POST /consents
  # POST /consents.json
  def create
    @consent = Consent.new(params[:consent])

    respond_to do |format|
      if @consent.save
        format.html { redirect_to @consent, :notice => 'Consent was successfully created.' }
        format.json { render :json => @consent, :status => :created, :location => @consent }
      else
        format.html { render :action => "new" }
        format.json { render :json => @consent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /consents/1
  # PUT /consents/1.json
  def update
    @consent = Consent.find(params[:id])
    
    t_hit = 0
    
    @trials = Trial.all
    @trials.each do |t|
      if @consent.trial.id == t.id
        t_hit = t.id
      end
    end
    
    #p_hit = 0
    #
    #@patients = Patient.all
    #@patients.each do |p|
    #  if @consent.subject.prename == p.prename && @consent.subject.surname == p.surname && @consent.trial.id == p.trial_id
    #    p_hit = p.id
    #  end
    #end
    #
    #@patient = Patient.find(p_hit)
    
    @trial = Trial.find(t_hit)
    status = @trial.recruiting_status

    if params[:consent][:status] == '0'
      @trial.update_attributes(:recruiting_status => status - 1)
      #@patient.update_attributes(:consent_status => 0)
    else
      @trial.update_attributes(:recruiting_status => status + 1)
      #@patient.update_attributes(:consent_status => 1)
    end
    
    respond_to do |format|
      if @consent.update_attributes(params[:consent])
        format.html { redirect_to @consent, :notice => 'Consent was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @consent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /consents/1
  # DELETE /consents/1.json
  def destroy
    @consent = Consent.find(params[:id])
    @consent.destroy

    respond_to do |format|
      format.html { redirect_to consents_url }
      format.json { head :ok }
    end
  end

  private
  
  def sort_column
    Consent.column_names.include?(params[:sort]) ? params[:sort] : "trial_id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
