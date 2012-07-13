require 'test_helper'

class ConsentsControllerTest < ActionController::TestCase
  setup do
    @consent = consents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:consents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create consent" do
    assert_difference('Consent.count') do
      post :create, :consent => @consent.attributes
    end

    assert_redirected_to consent_path(assigns(:consent))
  end

  test "should show consent" do
    get :show, :id => @consent.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @consent.to_param
    assert_response :success
  end

  test "should update consent" do
    put :update, :id => @consent.to_param, :consent => @consent.attributes
    assert_redirected_to consent_path(assigns(:consent))
  end

  test "should destroy consent" do
    assert_difference('Consent.count', -1) do
      delete :destroy, :id => @consent.to_param
    end

    assert_redirected_to consents_path
  end
end
