class PermissionsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  # POST /permissions
  # POST /permissions.json
  def create
    @group = Group.find(params[:group_id])
    @permission = @group.permissions.create(params[:permission])
    redirect_to group_path(@group)
  end

  # DELETE /criteria/1
  # DELETE /criteria/1.json
  def destroy
    @group = Group.find(params[:group_id])
    @permission = @group.permissions.find(params[:id])
    @permission.destroy
    redirect_to group_path(@group)
  end
end
