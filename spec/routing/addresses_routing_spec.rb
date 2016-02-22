require 'rails_helper'

RSpec.describe AddressesController, type: :routing do
  describe "direct routing" do
    it "routes to #index" do
      expect(get: "/addresses").not_to be_routable
    end

    it "does not route to #new" do
      expect(get: "/addresses/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/addresses/1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(get: "/addresses/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/addresses").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/addresses/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/addresses/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/addresses/1").not_to be_routable
    end
  end

  describe "typed_routing routing" do
    it "creditors routes to #index" do
      expect(get: "/creditors").to route_to("addresses#index", type: 'Creditor')
    end

    it "creditors routes to #index with formt csv" do
      expect(get: "/creditors?format=csv").to route_to("addresses#index", type: 'Creditor', format: 'csv')
    end

    [:organizations, :people, :project_addresses].each do |resource|
      it "#{resource} does not route to #index" do
        expect(get: "/#{resource}").not_to be_routable
      end
    end

    [:creditors, :organizations, :people, :project_addresses].each do |resource|
      context "#{resource}" do
        let(:parent){ resource.to_s.singularize }
        let(:type){ { type: parent.camelize } }
        let(:typed_params){ type.merge(id: "1") }

        it "does not route to #new" do
          expect(get: "/#{resource}/new").to route_to("addresses#new", type)
        end

        it "routes to #show" do
          expect(get: "/#{resource}/1").to route_to("addresses#show", typed_params)
        end

        it "routes to #edit" do
          expect(get: "/#{resource}/1/edit").to route_to("addresses#edit", typed_params)
        end

        it "routes to #create" do
          expect(post: "/#{resource}").to route_to("addresses#create", type)
        end

        it "routes to #update via PUT" do
          expect(put: "/#{resource}/1").to route_to("addresses#update", typed_params)
        end

        it "routes to #update via PATCH" do
          expect(patch: "/#{resource}/1").to route_to("addresses#update", typed_params)
        end

        it "routes to #destroy" do
          expect(delete: "/#{resource}/1").to route_to("addresses#destroy", typed_params)
        end
      end
    end
  end
end
