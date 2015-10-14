require 'rails_helper'

RSpec.describe AddressesController, type: :controller do
  #NOTE (conditional) Redirects are specified in feature/creditors/redirects_spec.rb
  describe "Get index for creditors" do
    it "assigns all the creditors and renders index" do
      person = create :person
      organization = create :organization
      get :index, type: 'Creditor'
      expect(assigns(:addresses)).to eq([person, organization])
    end

    it "assigns the type" do
      get :index, type: 'Creditor'
      expect(assigns(:type)).to eq('Creditor')
    end

    it "renders index" do
      person = create :person
      organization = create :organization
      get :index, type: 'Creditor'
      expect(response).to render_template(:index)
    end
  end

  ['Person', 'Organization', 'ProjectAddress'].each do |type|
    describe "Get show #{type}" do
      before(:each){ @address = create type.underscore.to_sym }
      it "assigns the #{type} as address" do
        get :show, type: type, id: @address
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "renders addresses#show" do
        get :show, type: type, id: @address
        expect(response).to render_template(:show)
      end
    end

    describe "Get new #{type}" do
      it "assigns the a new #{type} as address" do
        get :new, type: type
        expect(assigns(:address)).to be_a(type.constantize)
        expect(assigns(:type)).to eq(type)
      end

      it "renders new" do
        get :new, type: type
        expect(response).to render_template(:new)
      end
    end

    describe "Get edit #{type}" do
      before(:each){ @address = create type.underscore.to_sym }

      it "assigns the requested #{type} as address" do 
        get :edit, type: type, id: @address
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "renders edit" do
        get :edit, type: type, id: @address
        expect(response).to render_template(:edit)
      end
    end

    describe "Post create #{type}" do
      it "assigns the requested #{type} as address" do 
        post :create, type: type, type.underscore => attributes_for(type.underscore)
        expect(assigns(:address)).to be_a(type.constantize)
        expect(assigns(:type)).to eq(type)
      end

      it "is successfull" do
        post :create, type: type, type.underscore => attributes_for(type.underscore)
        expect(response.status).to eq 302
      end

      it "renders the new template if it fails" do
        allow_any_instance_of(type.constantize).to receive(:save).and_return(false)
        allow_any_instance_of(type.constantize).to receive(:errors).and_return(base: 'Failure')
        expect{
          post :create, type: type, type.underscore => attributes_for(type.underscore)
        }.not_to change{type.constantize.count}
        expect(response).to render_template(:new)  
      end
    end

    describe "Put update #{type}" do
      before(:each){ @address = create type.underscore.to_sym }

      it "assigns the requested #{type} as address" do 
        put :update, type: type, id: @address, type.underscore => attributes_for(type.underscore)
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "is successfull" do
        put :update, type: type, id: @address, type.underscore => attributes_for(type.underscore)
        expect(response.status).to eq 302
      end

      it "rerenders the edit template if not successfull" do
        allow_any_instance_of(type.constantize).to receive(:save).and_return(false)
        allow_any_instance_of(type.constantize).to receive(:errors).and_return(base: 'Failure')
        put :update, type: type, id: @address, type.underscore => attributes_for(type.underscore)
        expect(response).to render_template(:edit)
      end
    end

    describe "delete destroy #{type}" do
      before(:each){ @address = create type.underscore.to_sym }

      it "assigns the requested #{type} as address" do 
        delete :destroy, type: type, id: @address
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "is successfull" do
        expect{ 
          delete :destroy, type: type, id: @address
        }.to change{ type.constantize.count }
      end

      it "is not successfull" do
        allow_any_instance_of(type.constantize).to receive(:destroy).and_return(:false)
        allow_any_instance_of(type.constantize).to receive(:errors).and_return(base: 'Failure')
        expect{
          delete :destroy, type: type, id: @address
        }.not_to change{type.constantize.count}
      end
    end
  end
end

