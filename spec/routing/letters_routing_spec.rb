require 'rails_helper'

RSpec.describe LettersController, type: :routing do
  it "routes to index" do
    expect(get: "/letters").to route_to('letters#index', type: 'Letter')
  end

  it "does not route to show" do
    expect(get: "/letters/1").not_to be_routable
  end

  it "does not route to new" do
    expect(get: "/letters/new").not_to be_routable
  end

  it "does not route to edit" do
    expect(get: "/letters/1/edit").not_to be_routable
  end

  it "does not route to create" do
    expect(post: "/letters").not_to be_routable
  end

  it "does not rout to update" do
    expect(put: "/letters/1").not_to be_routable
  end

  it "does not route to destroy" do
    expect(delete: "/letters/1").not_to be_routable
  end

  describe "STI routing" do
    [:standard_letters, :balance_letters, :termination_letters].each do |resource|
      context "#{resource}" do
        let(:parent){ resource.to_s.singularize }
        let(:type){ { type: parent.camelize } }
        let(:typed_params){ type.merge(id: "1") }

        it "does not route to index" do
          expect(get: "/#{resource}").not_to be_routable
        end

        it "routes to #new" do
          expect(get: "/#{resource}/new").to route_to("letters#new", type)
        end

        it "routes to #show" do
          expect(get: "/#{resource}/1").to route_to("letters#show", typed_params)
        end

        it "does not route to #edit" do
          expect(get: "/#{resource}/1/edit").to route_to("letters#edit", typed_params)
        end

        it "does not route to #create" do
          expect(post: "/#{resource}").to route_to("letters#create", type)
        end

        it "does not route to #update via PUT" do
          expect(put: "/#{resource}/1").to route_to("letters#update", typed_params)
        end

        it "does not route to #update via PATCH" do
          expect(patch: "/#{resource}/1").to route_to("letters#update", typed_params)
        end

        it "does not route to #destroy" do
          expect(delete: "/#{resource}/1").to route_to("letters#destroy", typed_params)
        end

      end
    end
  end
end

