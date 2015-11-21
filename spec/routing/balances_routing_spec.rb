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

  describe "STI-routes" do
    [:auto_balances, :manual_balances].each do |balance_type|
      context "#{balance_type}" do
        let(:type){ balance_type.to_s.singularize.camelcase }

        it "does not route to #index" do
          expect(get: nested("/#{balance_type}")).not_to be_routable
        end

        it "does not route to #show" do
          expect(get: nested("/#{balance_type}/1")).not_to be_routable
          expect(get: nested("/#{balance_type}/1.pdf")).not_to be_routable
        end

        it "routes to edit" do
          expect(get: nested("/#{balance_type}/1/edit")).to route_to("balances#edit", id: "1", credit_agreement_id: "1", type: type)
        end

        it "does not route to create" do
          expect(post: nested("/#{balance_type}")).not_to be_routable
        end

        it "routes to update" do
          expect(patch: nested("/#{balance_type}/1")).to route_to("balances#update", id: "1", credit_agreement_id: "1", type: type)
        end

      end
    end

    context "auto_balances" do
      it "routes to destroy" do
        expect(delete: nested("/auto_balances/1")).not_to be_routable
      end
    end

    context "manual_balances" do
      it "routes to destroy" do
        expect(delete: nested("/manual_balances/1")).to route_to("balances#destroy", id: "1", credit_agreement_id: "1", type: 'ManualBalance')
      end
    end

    context "termination_balance" do
      it "does not route to #index" do
        expect(get: nested("/termination_balances")).not_to be_routable
      end

      it "does not route to #show" do
        expect(get: nested("/termination_balances/1")).not_to be_routable
        expect(get: nested("/termination_balances/1.pdf")).not_to be_routable
      end

      it "does not route to new" do
        expect(get: nested("/termination_balances/new")).not_to be_routable
      end

      it "does not route to edit" do
        expect(get: nested("/termination_balances/1/edit")).not_to be_routable
      end

      it "does not route to create" do
        expect(post: nested("/termination_balances")).not_to be_routable
      end

      it "does not route to update" do
        expect(patch: nested("/termination_balances/1")).not_to be_routable
      end

      it "routes to destroy" do
        expect(delete: nested("/termination_balances/1")).to route_to("balances#destroy", id: "1", credit_agreement_id: "1", type: 'TerminationBalance')
      end
    end
  end

  def nested(string)
    "/credit_agreements/1#{string}"
  end
end
