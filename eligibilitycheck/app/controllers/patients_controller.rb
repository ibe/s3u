class PatientsController < ApplicationController
  
  before_filter :authenticate_user!

  helper_method :sort_column, :sort_direction

  # GET /patients
  # GET /patients.json
  def index
    @patients = Patient.where(:extDocId => current_user.extDocId).order(sort_column + ' ' + sort_direction).page params[:page]

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
    
    # we need to update two remote applications: consentmanager + cdms
    # (the trial's recruiting status is indirectly updated via consentmanager)
    
    @cdms_subject = CdmsSubject.new(:prename => @patient.prename, :surname => @patient.surname)
    if @cdms_subject.new?
      @cdms_subject.save!
    else
      @cdms_subject.update   
    end
    
    @subject = Subject.new(:prename => @patient.prename, :surname => @patient.surname)
    if @subject.new?
      @subject.save!
    else
      @subject.update 
    end
    
    # question: why not put this code into the corresponding model?
    # answer: because any "current_user"-relevant code should/can not be used inside
    #         a model and belongs inside a controller
    
    @consent = Consent.new(:subject_id => @subject.id, :trial_id => @patient.trial.id)
    if @consent.new?
      @consent.status = params[:patient][:consent_status]
      @consent.prenamePhysician = current_user.prenameDoc
      @consent.surnamePhysician = current_user.surnameDoc
      @consent.mailPhysician = current_user.mailDoc
      @consent.save!
    
    # there is no else branch:
    # only the initial consent (regardless if positive or negative) is issued from here
    # further changes of the consent must be issued from the consent manager
    
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

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    respond_to do |format|
      format.html { redirect_to patients_url }
      format.json { head :ok }
    end
  end

  private
  
  def sort_column
    Patient.column_names.include?(params[:sort]) ? params[:sort] : "consent_status"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
