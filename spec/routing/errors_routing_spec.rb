require 'rails_helper'

RSpec.describe ErrorsController, type: :routing do
  it "routes to not_found" do
    expect(get: '/404').to route_to('errors#not_found')
  end

  it "routes to change_rejected" do
    expect(get: '/422').to route_to('errors#change_rejected')
  end

  it "routes to internal_server_error" do
    expect(get: '/500').to route_to('errors#internal_server_error')
  end

end

