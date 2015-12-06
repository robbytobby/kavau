require 'rails_helper'

RSpec.describe PdfsController, type: :routing do
  it "routes to show with format pdf" do
    expect(get: "/pdfs/1.pdf").to route_to("pdfs#show", id: "1", format: "pdf")
  end

  it "roues to :update" do
    expect(put: "pdfs/1").to route_to("pdfs#update", id: "1")
  end

  it "routes to :destroy" do
    expect(delete: "pdfs/1").to route_to("pdfs#destroy", id: "1")
  end

  [:organizations, :people].each do |parents|
    describe "nested in #{parents}" do
      let(:nesting){ "/#{parents}/1" }
      let(:parent){ parents.to_s.singularize }
      let(:parent_params){ { "#{parent}_id" => "1", type: parent.camelcase } }
      
      it "routes to new" do
        expect(get nesting + "/pdfs/new").to route_to("pdfs#new", parent_params)
      end

      it "routes to create" do
        expect(post nesting + "/pdfs").to route_to("pdfs#create", parent_params)
      end
    end
  end
end

