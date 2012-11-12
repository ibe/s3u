class MessagesController < ApplicationController

  # for every action except :search, use devise/devise_ldap_authenticatable as
  # authentication backend
  # for :search use basic http authentication instead
  # see https://github.com/plataformatec/devise/issues/2030
  before_filter :authenticate_user!
  skip_before_filter :authenticate_user!, :only => :search
  load_and_authorize_resource
  skip_load_and_authorize_resource :only => :search
  http_basic_authenticate_with :name => S3uLmuHl7interface::Application.config.REST_username, :password => S3uLmuHl7interface::Application.config.REST_password, :only => :search

  helper_method :sort_column, :sort_direction
  
  # GET /messages
  # GET /messages.json
  def index
    if (current_user.admin?)
      @messages = Message.order(sort_column + ' ' + sort_direction).page params[:page]
    else
      @mymessages = Message.where(current_user.permissions)
      @messages = Message.where(:messageControlId => @mymessages.collect{|x| x.messageControlId}).order(sort_column + ' ' + sort_direction).page params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @messages }
    end
  end

  # GET /messages/search
  # GET /messages/search.json
  def search
    #
    # for debug purposes, this action is right now implemented as GET action
    # instead of POST action (see routes.rb)
    #
    
    # expects exactly one of these parameter combinations:
    # either localhost:3000/messages/search?patid=01234
    # or     localhost:3000/messages/search?caseid=34567
    # or     localhost:3000/messages/search?patprename=Max&patsurname=Mustermann&patbirthdate=YYYYMMDD
    pat_id = params[:patid]
    case_id = params[:caseid]
    pat_prename = params[:patprename]
    pat_surname = params[:patsurname]
    pat_birthdate = params[:patbirthdate]
    
    if !pat_id.blank?
      @messageControlIds = Message.where(:segment => 'PID', :composite => 3, :subcomposite => 0, :subsubcomposite => 0, :value => pat_id)
    elsif !case_id.blank?
      @messageControlIds = Message.where(:segment => 'PV1', :composite => 19, :subcomposite => 0, :subsubcomposite => 0, :value => case_id)
    elsif !pat_prename.blank? and !pat_surname.blank? and !pat_birthdate.blank?
      temp1 = Message.where(:segment => 'PID', :composite => 5, :subcomposite => 0, :subsubcomposite => 0, :value => pat_prename)
      temp2 = Message.where(:segment => 'PID', :composite => 5, :subcomposite => 1, :subsubcomposite => 0, :value => pat_surname, :messageControlId => temp1.collect{|x| x.messageControlId})
      @messageControlIds = Message.where(:segment => 'PID', :composite => 7, :subcomposite => 0, :subsubcomposite => 0, :value => pat_birthdate, :messageControlId => temp2.collect{|x| x.messageControlId})
    end
    
    @messages = Message.where(:messageControlId => @messageControlIds.collect{|x| x.messageControlId})

    respond_to do |format|
      format.html
      format.json { render :json => @messages }
    end
  end
  
  private
  
  def sort_column
    Message.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end

