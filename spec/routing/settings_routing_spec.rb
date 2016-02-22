require "rails_helper"

RSpec.describe SettingsController, type: :routing do
  describe "direct_routing" do
    it "routes to #index" do
      expect(:get => "/settings").to route_to("settings#index")
    end

    it "does not route to #new" do
      expect(:get => "/settings/new").not_to be_routable
    end

    it "does not route to #show" do
      expect(:get => "/settings/1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(:get => "/settings/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(:post => "/settings").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/settings/1").to route_to("settings#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/settings/1").to route_to("settings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/settings/1").to route_to("settings#destroy", :id => "1")
    end
  end

  describe "typed_routing routing" do
    [:string_settings, :text_settings, :array_settings, :integer_settings, :float_settings, :file_settings, :boolean_settings].each do |resource|
      context "#{resource}" do
        let(:parent){ resource.to_s.singularize }
        let(:type){ {type: parent.camelize}}
        let(:typed_params){ type.merge(id: "1") }

        it "does not route to #new" do
          expect(get: "/#{resource}/new").not_to be_routable
        end

        it "does not route to #show" do
          expect(get: "/#{resource}/1").not_to be_routable
        end

        it "does not routes to #edit" do
          expect(get: "/#{resource}/1/edit").not_to be_routable
        end

        it "does not route to #create" do
          expect(post: "/#{resource}").not_to be_routable
        end

        it "routes to #update via PUT" do
          expect(put: "/#{resource}/1").to route_to("settings#update", typed_params)
        end

        it "routes to #update via PATCH" do
          expect(patch: "/#{resource}/1").to route_to("settings#update", typed_params)
        end

        it "routes to #destroy" do
          expect(delete: "/#{resource}/1").to route_to("settings#destroy", typed_params)
        end
      end
    end
  end
end
