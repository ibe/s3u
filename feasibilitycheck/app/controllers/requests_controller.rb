class RequestsController < ApplicationController
  
  before_filter :authenticate_user!, :only => [ :index, :destroy ]

  helper_method :sort_column, :sort_direction

  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.order(sort_column + ' ' + sort_direction).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @request }
    end
  end

  # GET /requests/new
  # GET /requests/new.json
  def new
    @request = Request.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @request }
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(params[:request])

    respond_to do |format|
      if @request.save
        @url = root_url + @request.id.to_s
        RequestMailer.welcome_email(@request, @url).deliver
        
        format.html { redirect_to @request, :notice => 'Request was successfully created.' }
        format.json { render :json => @request, :status => :created, :location => @request }
      else
        format.html { render :action => "new" }
        format.json { render :json => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /requests/1
  # PUT /requests/1.json
  def update
    @request = Request.find(params[:id])

    respond_to do |format|
      if @request.update_attributes(params[:request])
        format.html { redirect_to @request, :notice => 'Request was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request = Request.find(params[:id])
    @request.destroy

    respond_to do |format|
      format.html { redirect_to requests_url }
      format.json { head :ok }
    end
  end

  private
  
  def sort_column
    Request.column_names.include?(params[:sort]) ? params[:sort] : "approved"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
