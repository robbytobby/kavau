require 'rails_helper'

RSpec.describe PdfsController, type: :controller do
  before(:each){ sign_in create(:accountant) }

  describe "Get show" do
    before(:each){ @pdf = create :pdf }

    it "assigns the pdf as @pdf" do
      get :show, params: { id: @pdf.id }, format: 'pdf'
      expect(assigns(:pdf)).to eq(@pdf)
    end

    it "responds with the pdf_file" do
      get :show, params: { id: @pdf.id }, format: 'pdf'
      expect(response.body).to eq(IO.binread(@pdf.path))
    end

    it "is successfull" do
      get :show, params: { id: @pdf.id }, format: 'pdf'
      expect(response.status).to eq(200)
    end
  end

  ['Organization', 'Person'].each do |type|
    describe "Get new" do
      let(:address_params) { {type: type, "#{type.underscore}_id": @address.id} }
      before(:each){@address = create type.underscore.to_sym}

      it "assigns a new pdf as @pdf" do
        get :new, params: address_params
        expect(assigns(:pdf)).to be_a_new(Pdf)
      end

      it "assignes the corresponding address as @address" do
        get :new, params: address_params
        expect(assigns(:address)).to eq(@address)
      end

      it "renders the new template" do
        get :new, params: address_params
        expect(response).to render_template(:new)
      end
    end

    describe "Post create for #{type}" do
      before :each  do
        @address = create type.underscore.to_sym
        @letter = create :standard_letter 
        allow_any_instance_of(StandardLetter).to receive(:to_pdf).and_return(true) 
      end
      let(:address_params) { {type: type, "#{type.underscore}_id": @address.id} }
      let(:valid_params){ { pdf: {letter_id: @letter.id} } }

      context "with valid params" do
        it "creates a new pdf" do
          expect {
            post :create, params: valid_params.merge(address_params) 
          }.to change(Pdf, :count).by(1)
        end

        it "assigns a newly created pdf as @pdf" do
          post :create, params: valid_params.merge(address_params)
          expect(assigns(:pdf)).to be_a(Pdf)
          expect(assigns(:pdf)).to be_persisted
          expect(assigns(:address)).to eq(@address)
        end

        it "redirects to the accounts address" do
          post :create, params: valid_params.merge(address_params)
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        before(:each){ do_not(:save, Pdf) }

        it "assgigns a new pdf as @pdf" do
          post :create, params: valid_params.merge(address_params)
          expect(assigns(:pdf)).to be_a_new(Pdf)
          expect(assigns(:address)).to eq(@address)
        end

        it "re-renders the new template" do
          post :create, params: valid_params.merge(address_params)
          expect(response).to render_template("new")
        end
      end
    end
  end

  describe "Put update" do
    before(:each){ @pdf = create :pdf }

    it "assigns the pdf as @pdf" do
      put :update, params: { id: @pdf.id }
      expect(assigns(:pdf)).to eq(@pdf)
    end

    it "update the pdf_file" do
      allow_any_instance_of(Pdf).to receive(:update_file).and_return(:true)
      put :update, params: { id: @pdf.id }
      expect(assigns(:pdf)).to have_received(:update_file)
    end

    it "is successfull" do
      put :update, params: { id: @pdf.id }
      expect(response.status).to eq(302)
    end
  end

  describe "Delete destroy" do
    before(:each){ @pdf = create :pdf }

    it "assigns the pdf as @pdf" do
      delete :destroy, params: { id: @pdf.id }
      expect(assigns(:pdf)).to eq(@pdf)
    end

    it "destroys the requested pdf" do
      expect {
        delete :destroy, params: { id: @pdf.id }
      }.to change(Pdf, :count).by(-1)
    end

    it "reirects to the creditor" do
      delete :destroy, params: { id: @pdf.id }
      expect(response).to redirect_to(@pdf.creditor)
    end
  end
end

