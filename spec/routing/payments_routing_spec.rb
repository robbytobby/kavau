require 'rails_helper'

RSpec.describe PaymentsController, type: :routing do
  describe "simple routing" do
    it "routes to #index" do
      expect(get: "/payments").to route_to('payments#index')
    end

    it "does not route to #new" do
      expect(get: "/payments/new").not_to be_routable
    end

    it "routes to #show" do
      expect(get: "/payments/1").not_to be_routable
    end

    it "routes to #show with format pdf" do
      expect(get: "payments/1.pdf").to route_to('payments#show', "id" => "1", "format" => "pdf")
    end

    it "does not route to #edit" do
      expect(get: "/payments/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/payments").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/payments/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/payments/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/payments/1").not_to be_routable
    end
  end

  [:deposits, :disburses, :payments].each do |type|
    describe "nested in credit_agreements as #{type}" do
      let(:type_params){ type == :payments ? {} : { type: type.to_s.singularize.camelcase } }
      let(:parent_params){ type_params.merge("credit_agreement_id" => "1") }


      it "does not route to #index" do
        expect(get: nested("/#{type}")).not_to be_routable
      end

      it "does not route to #show" do
        expect(get: nested("/#{type}/1")).not_to be_routable
      end

      it "routes to new" do
        expect(get: nested("/#{type}/new")).not_to be_routable
      end

      it "routes to edit" do
        expect(get: nested("/#{type}/1/edit")).to route_to("payments#edit", parent_params.merge(id: "1"))
      end

      it "routest to create" do
        expect(post: nested("/#{type}")).to route_to("payments#create", parent_params)
      end

      it "routes to update" do
        expect(patch: nested("/#{type}/1")).to route_to("payments#update", parent_params.merge(id: "1"))
      end

      it "routes to destroy" do
        expect(delete: nested("/#{type}/1")).to route_to("payments#destroy", parent_params.merge(id: "1"))
      end
    end

    def nested(string)
      "/credit_agreements/1#{string}"
    end
  end
end
