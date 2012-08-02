class PatientsController < ApplicationController
  
  before_filter :authenticate_user!

  helper_method :sort_column, :sort_direction

  # GET /patients
  # GET /patients.json
  def index
    @patients = Patient.where(:extDocId => current_user.extDocId).order(sort_column + ' ' + sort_direction)

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
    
    cs_hit = 0
    @cdms_subjects = CdmsSubject.all
    @cdms_subjects.each do |cs|
      if cs.prename == @patient.prename && cs.surname == @patient.surname
        cs_hit = cs.id
      end
    end
    if cs_hit > 0
      @cdms_subject = CdmsSubject.find(cs_hit)
      @cdms_subject.update_attributes(:prename => @patient.prename, :surname => @patient.surname)
    else
      @cdms_subject = CdmsSubject.new(
        :prename => @patient.prename,
        :surname => @patient.surname
      )
      @cdms_subject.save!
    end
    
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
