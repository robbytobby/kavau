require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe "GET #not_found" do
    it "returns Not Found" do
      get :not_found
      expect(response.status).to eq(404)
    end

    it "renders not found template" do
      get :not_found
      expect(response).to render_template(:not_found)
    end
  end

  describe "GET #change_rejected" do
    it "returns change_rejected" do
      get :change_rejected
      expect(response.status).to eq(422)
    end

    it "renders change rejected template" do
      get :change_rejected
      expect(response).to render_template(:change_rejected)
    end
  end

  describe "GET #internal_server_error" do
    it "returns internal_server_error success" do
      get :internal_server_error
      expect(response.status).to eq(500)
    end

    it "renders internal server error template" do
      get :internal_server_error
      expect(response).to render_template(:internal_server_error)
    end
  end
end
