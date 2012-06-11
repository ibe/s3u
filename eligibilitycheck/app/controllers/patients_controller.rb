class PatientsController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /patients
  # GET /patients.json
  def index
    @patients = Patient.where(:extDocId => current_user.extDocId).order("consent_status ASC, created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patients }
    end
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
    @patient = Patient.where(:extDocId => current_user.extDocId).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @patient }
    end
  end
  
  # GET /patients/1/edit
  def edit
    @patient = Patient.find(params[:id])
  end

  # PUT /patients/1
  # PUT /patients/1.json
  def update
    @patient = Patient.find(params[:id])
    
    # as Subject and Consent models are ActiveRessource based,
    # update/insert is not *that* easy as with ActiveRecord based models
    # maybe we have to re-design this at a later stage due to privacy concerns
    
    s_hit = 0
    
    # let's search for "our" patient
    @subjects = Subject.all
    @subjects.each do |s|
      # need to specify patient in a more detailed way
      if s.prename == @patient.prename && s.surname == @patient.surname
        s_hit = s.id
      end
    end

    # ok, found => update
    if s_hit > 0
      @subject = Subject.find(s_hit)
      @subject.update_attributes(:prename => @patient.prename, :surname => @patient.surname)
    # not found => insert
    else
        @subject = Subject.new(
          :prename => @patient.prename,
          :surname => @patient.surname
        )
        @subject.save!
        s_hit = @subject.id
    end
    
    c_hit = 0
    
    # let's search for "our" consent
    @consents = Consent.all
    @consents.each do |c|
      if c.subject_id == s_hit && c.trial_id == @patient.trial.id
        c_hit = c.id
      end
    end
    
    if c_hit > 0
      @consent = Consent.find(c_hit)
      @consent.update_attributes(
        :status => params[:patient][:consent_status],
        :prenamePhysician => current_user.prenameDoc,
        :surnamePhysician => current_user.surnameDoc,
        :mailPhysician => current_user.mailDoc
      )
    else
      @consent = Consent.new(
        :subject_id => @subject.id,
        :trial_id => @patient.trial.id,
        :status => params[:patient][:consent_status],
        :prenamePhysician => current_user.prenameDoc,
        :surnamePhysician => current_user.surnameDoc,
        :mailPhysician => current_user.mailDoc
      )
      @consent.save!
    end
    
    @trial = Trial.find(@patient.trial.id)
    status = @trial.recruiting_status || 0
    if @consent.status == '0'
      @trial.update_attribute(:recruiting_status, status - 1)
    else
      @trial.update_attribute(:recruiting_status, status + 1)
    end

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_to @patient, :notice => 'Patient was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @patient.errors, :status => :unprocessable_entity }
      end
    end
  end
end
