require 'test_helper'

class PhysiciansControllerTest < ActionController::TestCase
  setup do
    @physician = physicians(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:physicians)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create physician" do
    assert_difference('Physician.count') do
      post :create, physician: @physician.attributes
    end

    assert_redirected_to physician_path(assigns(:physician))
  end

  test "should show physician" do
    get :show, id: @physician.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @physician.to_param
    assert_response :success
  end

  test "should update physician" do
    put :update, id: @physician.to_param, physician: @physician.attributes
    assert_redirected_to physician_path(assigns(:physician))
  end

  test "should destroy physician" do
    assert_difference('Physician.count', -1) do
      delete :destroy, id: @physician.to_param
    end

    assert_redirected_to physicians_path
  end
end
