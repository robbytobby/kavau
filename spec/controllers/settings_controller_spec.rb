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
        xhr :put, :update, valid_params
        expect(@setting.reload.value).to eq('NewValue')
      end

      it "assigns the requested setting as @setting" do
        xhr :put, :update, valid_params
        expect(assigns(:setting)).to eq(@setting)
      end

      it "renders the update template" do
        xhr :put, :update, valid_params
        expect(response).to render_template(:update)
      end
    end

    context "with invalid params" do
      before(:each){ @setting = create :integer_setting }
      let(:invalid_params) { {id: @setting.id, type: 'IntegerSetting', integer_setting: {value: 'abc'}} }

      it "assigns the setting as @setting" do
        xhr :put, :update, invalid_params
        expect(assigns(:setting)).to eq(@setting)
      end

      it "renders the 'update' template" do
        xhr :put, :update, invalid_params
        expect(response).to render_template(:update)
      end
    end
  end

  describe "DELETE #destroy" do
    it "does calls destroy on the requested setting" do
      expect_any_instance_of(Setting).to receive(:destroy)
      xhr :delete, :destroy, {:id => @setting.to_param}
    end

    it "renders the update template" do
      xhr :delete, :destroy, {:id => @setting.to_param}
      expect(response).to render_template(:update)
    end
  end
end
