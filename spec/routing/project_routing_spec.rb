require 'rails_helper'

RSpec.describe ProjectController, type: :routing do
  describe "simple routing" do
    it "routes to show" do
      expect(get: "/project").to route_to('project#show')
    end

    it "does not route to #new" do
      expect(get: "/project/new").not_to be_routable
    end

    it "does not route to #show" do
      expect(get: "/project/1").not_to be_routable
    end

    it "does not route to #edit" do
      expect(get: "/project/1/edit").not_to be_routable
    end

    it "does not route to #create" do
      expect(post: "/project").not_to be_routable
    end

    it "does not route to #update via PUT" do
      expect(put: "/project/1").not_to be_routable
    end

    it "does not route to #update via PATCH" do
      expect(patch: "/project/1").not_to be_routable
    end

    it "does not route to #destroy" do
      expect(delete: "/project/1").not_to be_routable
    end
  end
end

