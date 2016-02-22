require 'rails_helper'

RSpec.describe SettingsController, type: :controller do

  let(:valid_attributes) { attributes_for(:setting) }

  describe "GET #index", focus: true do
    it "assigns all settings as @settings" do
      setting = create :setting, type: 'StringSetting'
      get :index
      expect(assigns(:settings)).to eq([setting])
    end
  end

  describe "GET #show" do
    it "assigns the requested setting as @setting" do
      setting = Setting.create! valid_attributes
      get :show, {:id => setting.to_param}, valid_session
      expect(assigns(:setting)).to eq(setting)
    end
  end

  describe "GET #new" do
    it "assigns a new setting as @setting" do
      get :new, {}, valid_session
      expect(assigns(:setting)).to be_a_new(Setting)
    end
  end

  describe "GET #edit" do
    it "assigns the requested setting as @setting" do
      setting = Setting.create! valid_attributes
      get :edit, {:id => setting.to_param}, valid_session
      expect(assigns(:setting)).to eq(setting)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Setting" do
        expect {
          post :create, {:setting => valid_attributes}, valid_session
        }.to change(Setting, :count).by(1)
      end

      it "assigns a newly created setting as @setting" do
        post :create, {:setting => valid_attributes}, valid_session
        expect(assigns(:setting)).to be_a(Setting)
        expect(assigns(:setting)).to be_persisted
      end

      it "redirects to the created setting" do
        post :create, {:setting => valid_attributes}, valid_session
        expect(response).to redirect_to(Setting.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved setting as @setting" do
        post :create, {:setting => invalid_attributes}, valid_session
        expect(assigns(:setting)).to be_a_new(Setting)
      end

      it "re-renders the 'new' template" do
        post :create, {:setting => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested setting" do
        setting = Setting.create! valid_attributes
        put :update, {:id => setting.to_param, :setting => new_attributes}, valid_session
        setting.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested setting as @setting" do
        setting = Setting.create! valid_attributes
        put :update, {:id => setting.to_param, :setting => valid_attributes}, valid_session
        expect(assigns(:setting)).to eq(setting)
      end

      it "redirects to the setting" do
        setting = Setting.create! valid_attributes
        put :update, {:id => setting.to_param, :setting => valid_attributes}, valid_session
        expect(response).to redirect_to(setting)
      end
    end

    context "with invalid params" do
      it "assigns the setting as @setting" do
        setting = Setting.create! valid_attributes
        put :update, {:id => setting.to_param, :setting => invalid_attributes}, valid_session
        expect(assigns(:setting)).to eq(setting)
      end

      it "re-renders the 'edit' template" do
        setting = Setting.create! valid_attributes
        put :update, {:id => setting.to_param, :setting => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested setting" do
      setting = Setting.create! valid_attributes
      expect {
        delete :destroy, {:id => setting.to_param}, valid_session
      }.to change(Setting, :count).by(-1)
    end

    it "redirects to the settings list" do
      setting = Setting.create! valid_attributes
      delete :destroy, {:id => setting.to_param}, valid_session
      expect(response).to redirect_to(settings_url)
    end
  end

end
