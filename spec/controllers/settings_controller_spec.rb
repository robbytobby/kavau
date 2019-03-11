require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  before(:each){
    @setting = create :string_setting
    @user = create :admin
    sign_in @user
  }
  let(:valid_attributes) { attributes_for(:setting) }

  describe "GET #index" do
    it "assigns all settings as @settings" do
      integer = create :integer_setting
      get :index
      expect(assigns(:settings)).to eq([@setting, integer])
    end
  end


  describe "PUT #update" do
    context "with valid params" do
      let(:valid_params) { {id: @setting.id, type: 'StringSetting', string_setting: {value: 'NewValue'}} }

      it "updates the requested setting" do
        put :update, params: valid_params, xhr: true
        expect(@setting.reload.value).to eq('NewValue')
      end

      it "assigns the requested setting as @setting" do
        put :update, params: valid_params, xhr: true
        expect(assigns(:setting)).to eq(@setting)
      end

      it "renders the update template" do
        put :update, params: valid_params, xhr: true
        expect(response).to render_template(:update)
      end
    end

    context "with invalid params" do
      before(:each){ @setting = create :integer_setting }
      let(:invalid_params) { {id: @setting.id, type: 'IntegerSetting', integer_setting: {value: 'abc'}} }

      it "assigns the setting as @setting" do
        put :update, params: invalid_params, xhr: true
        expect(assigns(:setting)).to eq(@setting)
      end

      it "renders the 'update' template" do
        put :update, params: invalid_params, xhr: true
        expect(response).to render_template(:update)
      end
    end
  end

  describe "DELETE #destroy" do
    it "does calls destroy on the requested setting" do
      expect_any_instance_of(Setting).to receive(:destroy)
      delete :destroy, params: {:id => @setting.to_param}, xhr: true
    end

    it "renders the update template" do
      delete :destroy, params: {:id => @setting.to_param}, xhr: true
      expect(response).to render_template(:update)
    end
  end
end
