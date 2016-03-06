require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  before(:each){ 
    sign_in create(:user) 
    request.env["HTTP_REFERER"] = '/back'
  }

  describe "Pundit::NotAuthorizedError" do
    controller do
      def test
        raise Pundit::NotAuthorizedError
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to('/back')
      expect(flash[:alert]).to eq 'Diese Aktion ist dir nicht gestattet'
    end
  end

  describe "NoAccountError" do
    controller do
      def test
        raise NoAccountError
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to '/back'
    end
  end
  
  describe "MissingInformationError" do
    controller do
      def test
        @address = FactoryGirl.create :project_address
        raise MissingInformationError.new(@address)
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to project_address_path(ProjectAddress.first)
    end
  end

  describe "MissingLetterTemplateError" do
    controller do
      def test
        raise MissingLetterTemplateError.new(BalanceLetter, 2015)
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to letters_path
      expect(flash[:alert]).to eq 'Es muß erst eine Vorlage für den Jahresabschluss 2015 angelegt werden.'
    end
  end

  describe "MissingRegisteredSocietyError" do
    controller do
      def test
        raise MissingRegisteredSocietyError
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to new_project_address_path
      expect(flash[:warning]).to eq 'Der Absender für jeden Brief ist der Hausverein. Es ist aber noch kein Hausverein angelegt, das mußt du erst noch tun, bevor du Briefe erstellen kannst.'
    end
  end

  describe "Prawn::Errors::CannotFit" do
    controller do
      def test
        raise Prawn::Errors::CannotFit.new
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to '/back'
      expect(flash[:alert]).to eq 'Das PDF paßt nicht auf ein A4 Format. Überprüfe die Einstellungen für die Seitenränder.'
    end
  end

  describe "MissingTemplateError" do
    controller do
      def test
        raise MissingTemplateError.new(group: 'templates', key: 'logo')
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to '/back'
      expect(flash[:alert]).to eq 'Die Datei für das Logo konnte nicht gefunden werden. Bitte das Logo neu hochladen.'
    end
  end

  describe "NoCreditorError" do
    controller do
      def test
        raise NoCreditorError
      end
    end

    it "is rescued" do
      routes.draw { get "test" => "anonymous#test" }
      get :test
      expect(response).to redirect_to '/back'
      expect(flash[:warning]).to include 'noch kein_e Kreditgeber_in'
    end
  end
end
