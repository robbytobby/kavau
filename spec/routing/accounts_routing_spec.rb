require 'rails_helper'

RSpec.describe AccountsController, type: :routing do
  describe "simple routing" do
    it "does not route to #index" do
      expect(get: "/accounts").not_to be_routable
    end

    it "does not route to #new" do
      expect(get: "/accounts/new").not_to be_routable
    end

    it "does not route to #show" do
      expect(get: "/accounts/1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(get: "/accounts/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/accounts").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/accounts/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/accounts/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/accounts/1").not_to be_routable
    end
  end

  [:organizations, :people, :project_addresses].each do |parents|
    describe "nested in credit agreements" do
      let(:nesting){ "/#{parents}/1" }
      let(:parent){ parents.to_s.singularize }
      let(:parent_params){ { "#{parent}_id" => "1", type: parent.camelcase } }

      it "does not route to #index" do
        expect(get: nesting + "/accounts").not_to be_routable
      end

      it "does not route to #show" do
        expect(get: nesting + "/accounts/1").not_to be_routable
      end

      it "routes to new" do
        expect(get: nesting + "/accounts/new").to route_to("accounts#new", parent_params)
      end

      it "routes to edit" do
        expect(get: nesting + "/accounts/1/edit").to route_to("accounts#edit", nested(id: "1"))
      end

      it "routest to create" do
        expect(post: nesting + "/accounts").to route_to("accounts#create", parent_params)
      end

      it "routes to update" do
        expect(patch: nesting + "/accounts/1").to route_to("accounts#update", nested(id: "1"))
      end

      it "routes to destroy" do
        expect(delete: nesting + "/accounts/1").to route_to("accounts#destroy", nested(id: "1"))
      end

      def nested(params)
        params.merge(parent_params)
      end
    end
  end
end
