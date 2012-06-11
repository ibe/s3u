require 'test_helper'

class CriteriaControllerTest < ActionController::TestCase
  setup do
    @criterion = criteria(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:criteria)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create criterion" do
    assert_difference('Criterion.count') do
      post :create, :criterion => @criterion.attributes
    end

    assert_redirected_to criterion_path(assigns(:criterion))
  end

  test "should show criterion" do
    get :show, :id => @criterion.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @criterion.to_param
    assert_response :success
  end

  test "should update criterion" do
    put :update, :id => @criterion.to_param, :criterion => @criterion.attributes
    assert_redirected_to criterion_path(assigns(:criterion))
  end

  test "should destroy criterion" do
    assert_difference('Criterion.count', -1) do
      delete :destroy, :id => @criterion.to_param
    end

    assert_redirected_to criteria_path
  end
end
