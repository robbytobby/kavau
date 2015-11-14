require 'rails_helper'

RSpec.describe ContactsController, type: :routing do
  describe "simple routing" do
    it "routes to #index" do
      expect(get: "/contacts").not_to be_routable
    end

    it "does not route to #new" do
      expect(get: "/contacts/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/contacts/1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(get: "/contacts/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/contacts").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/contacts/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/contacts/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/contacts/1").not_to be_routable
    end
  end

  [:organizations, :project_addresses].each do |resource|
    describe "nested in #{resource}" do
      let(:nesting){ resource }
      let(:parent){ resource.to_s.singularize.underscore }
      let(:type){ parent.camelcase }
      let(:parent_params){ { "#{parent}_id" => "1", type: type } }


      it "does not route to #index" do
        expect(get: nested("/contacts")).not_to be_routable
      end

      it "does not route to #show" do
        expect(get: nested("/contacts/1")).not_to be_routable
      end

      it "routes to new" do
        expect(get: nested("/contacts/new")).to route_to("contacts#new", parent_params)
      end

      it "routes to edit" do
        expect(get: nested("/contacts/1/edit")).to route_to("contacts#edit", parent_params.merge(id: "1"))
      end

      it "routest to create" do
        expect(post: nested("/contacts")).to route_to("contacts#create", parent_params)
      end

      it "routes to update" do
        expect(patch: nested("/contacts/1")).to route_to("contacts#update", parent_params.merge(id: "1"))
      end

      it "routes to destroy" do
        expect(delete: nested("/contacts/1")).to route_to("contacts#destroy", parent_params.merge(id: "1"))
      end
    end

    def nested(string)
      "/#{nesting}/1#{string}"
    end
  end
end
