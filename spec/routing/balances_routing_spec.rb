require 'rails_helper'

RSpec.describe BalancesController, type: :routing do
  describe "simple routing" do
    it "routes to #index" do
      expect(get: "/balances").to route_to("balances#index")
    end

    it "does not route to #new" do
      expect(get: "/balances/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/balances/1").not_to be_routable
      expect(get: "/balances/1.pdf").to route_to("balances#show", id: "1", format: "pdf")
    end

    it "does not route to #edit" do
      expect(get: "/balances/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/balances").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/balances/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/balances/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/balances/1").not_to be_routable
    end
  end

  describe "nested in credit agreements" do
    it "does not route to #index" do
      expect(get: nested("/balances")).not_to be_routable
    end

    it "does not route to #show" do
      expect(get: nested("/balances/1")).not_to be_routable
      expect(get: nested("/balances/1.pdf")).not_to be_routable
    end

    it "routes to new" do
      expect(get: nested("/balances/new")).to route_to("balances#new", credit_agreement_id: "1")
    end

    it "routes to edit" do
      expect(get: nested("/balances/1/edit")).to route_to("balances#edit", id: "1", credit_agreement_id: "1")
    end

    it "routest to create" do
      expect(post: nested("/balances")).to route_to("balances#create", credit_agreement_id: "1")
    end

    it "routes to update" do
      expect(patch: nested("/balances/1")).to route_to("balances#update", id: "1", credit_agreement_id: "1")
    end

    it "routes to destroy" do
      expect(delete: nested("/balances/1")).to route_to("balances#destroy", id: "1", credit_agreement_id: "1")
    end

  end

  def nested(string)
    "/credit_agreements/1#{string}"
  end
end
