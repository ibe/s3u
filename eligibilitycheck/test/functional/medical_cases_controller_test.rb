require 'test_helper'

class MedicalCasesControllerTest < ActionController::TestCase
  setup do
    @medical_case = medical_cases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:medical_cases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create medical_case" do
    assert_difference('MedicalCase.count') do
      post :create, :medical_case => @medical_case.attributes
    end

    assert_redirected_to medical_case_path(assigns(:medical_case))
  end

  test "should show medical_case" do
    get :show, :id => @medical_case.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @medical_case.to_param
    assert_response :success
  end

  test "should update medical_case" do
    put :update, :id => @medical_case.to_param, :medical_case => @medical_case.attributes
    assert_redirected_to medical_case_path(assigns(:medical_case))
  end

  test "should destroy medical_case" do
    assert_difference('MedicalCase.count', -1) do
      delete :destroy, :id => @medical_case.to_param
    end

    assert_redirected_to medical_cases_path
  end
end
