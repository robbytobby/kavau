require 'rails_helper'

RSpec.describe CreditAgreementsController, type: :routing do
  describe "simple routing" do
    it "routes to create_yearly_balances" do
      expect(get: "/credit_agreements/create_yearly_balances").to route_to('credit_agreements#create_yearly_balances')
    end

    it "routes to #index" do
      expect(get: "/credit_agreements").to route_to("credit_agreements#index")
    end

    it "does not route to #new" do
      expect(get: "/credit_agreements/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/credit_agreements/1").to route_to("credit_agreements#show", id: "1")
    end

    it "does not route to #edit" do
      expect(get: "/credit_agreements/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/credit_agreements").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/credit_agreements/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/credit_agreements/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/credit_agreements/1").not_to be_routable
    end
  end

  [:organizations, :people].each do |resource|
    describe "nested in #{resource}" do
      let(:nesting){ resource }
      let(:parent){ resource.to_s.singularize.underscore }
      let(:type){ parent.camelcase }
      let(:parent_params){ { "#{parent}_id" => "1", type: type } }


      it "does not route to #index" do
        expect(get: nested("/credit_agreements")).not_to be_routable
      end

      it "does not route to #show" do
        expect(get: nested("/credit_agreements/1")).not_to be_routable
      end

      it "routes to new" do
        expect(get: nested("/credit_agreements/new")).to route_to("credit_agreements#new", parent_params)
      end

      it "routes to edit" do
        expect(get: nested("/credit_agreements/1/edit")).to route_to("credit_agreements#edit", parent_params.merge(id: "1"))
      end

      it "routest to create" do
        expect(post: nested("/credit_agreements")).to route_to("credit_agreements#create", parent_params)
      end

      it "routes to update" do
        expect(patch: nested("/credit_agreements/1")).to route_to("credit_agreements#update", parent_params.merge(id: "1"))
      end

      it "routes to destroy" do
        expect(delete: nested("/credit_agreements/1")).to route_to("credit_agreements#destroy", parent_params.merge(id: "1"))
      end
    end

    def nested(string)
      "/#{nesting}/1#{string}"
    end
  end
end
