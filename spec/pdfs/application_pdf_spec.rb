require 'rails_helper'
require "prawn/measurement_extensions"

RSpec.describe LetterPdf do
  before :each do 
    @recipient = create :person
    @sender = create :complete_project_address
  end

  after(:each){ reset_config }

  context "logo" do
    it "is set" do
      Rails.application.config.kavau.pdf[:templates][:logo] = "#{Rails.root}/spec/support/templates/logo.png"
      expect_any_instance_of(PdfLogo).to receive(:render).and_call_original
      ApplicationPdf.new(@sender, @recipient)
    end

    it "is not set" do
      Rails.application.config.kavau.pdf[:templates][:logo] = nil
      expect_any_instance_of(PdfLogo).not_to receive(:render)
      ApplicationPdf.new(@sender, @recipient)
    end

    it "is set to a wrong path" do
      Rails.application.config.kavau.pdf[:templates][:logo] = 'wrong'
      expect(MissingTemplateError).to receive(:new).with(group: :templates, key: :logo).and_call_original
      expect{
        ApplicationPdf.new(@sender, @recipient)
      }.to raise_error(MissingTemplateError)
    end
  end

  context "watermark" do
    it "is set" do
      Rails.application.config.kavau.pdf[:templates][:watermark] = "#{Rails.root}/spec/support/templates/stempel.png"
      pdf = ApplicationPdf.new(@sender, @recipient)
      expect(pdf.send(:page_definition)[:background]).to eq "#{Rails.root}/spec/support/templates/stempel.png"
    end

    it "is not set" do
      Rails.application.config.kavau.pdf[:templates][:watermark] = nil
      pdf = ApplicationPdf.new(@sender, @recipient)
      expect(pdf.send(:page_definition)[:background]).to be_nil
    end

    it "is set to a wrong path" do
      Rails.application.config.kavau.pdf[:templates][:watermark] = 'wrong'
      expect(MissingTemplateError).to receive(:new).with(group: :templates, key: :watermark).and_call_original
      expect{
        ApplicationPdf.new(@sender, @recipient)
      }.to raise_error(MissingTemplateError)
    end
  end

  context "custom_fonts" do
    it "does setup a custom font if oll font faces are given" do
      [:normal, :italic, :bold, :bold_italic].each do |font|
        Rails.application.config.kavau.pdf[:custom_font][font] = "#{Rails.root}/spec/support/templates/font.ttf"
      end
      expect_any_instance_of(ApplicationPdf).to receive(:set_custom_font).and_call_original
      ApplicationPdf.new(@sender, @recipient)
    end

    [:normal, :italic, :bold, :bold_italic].each do |missing_font|
      it "does not setup a custom font if font face #{missing_font} is missing" do
        [:normal, :italic, :bold, :bold_italic].each do |font|
          Rails.application.config.kavau.pdf[:custom_font][font] = "#{Rails.root}/spec/support/templates/font.ttf"
        end
        Rails.application.config.kavau.pdf[:custom_font][missing_font] = nil
        expect_any_instance_of(ApplicationPdf).not_to receive(:set_custom_font)
        ApplicationPdf.new(@sender, @recipient)
      end
    end

    [:normal, :italic, :bold, :bold_italic].each do |error_font|
      it "raises an error if font face #{error_font} is set but path is wrong" do
        [:normal, :italic, :bold, :bold_italic].each do |font|
          Rails.application.config.kavau.pdf[:custom_font][font] = "#{Rails.root}/spec/support/templates/font.ttf"
        end
        Rails.application.config.kavau.pdf[:custom_font][error_font] = 'wrong'

        expect(MissingTemplateError).to receive(:new).with(group: :custom_font, key: error_font).and_call_original
        expect{
          ApplicationPdf.new(@sender, @recipient)
        }.to raise_error(MissingTemplateError)
      end
    end
  end

  context "margins" do
    [:bottom_margin, :top_margin, :right_margin, :left_margin].each do |margin|
      it "set #{margin} works" do
        Rails.application.config.kavau.pdf[:margins][margin] = 5
        pdf = ApplicationPdf.new(@sender, @recipient)
        expect(pdf.send(:page_definition)[margin]).to eq(5.cm)
      end
    end
  end

  context "page templates" do
    before :each do
      Rails.application.config.kavau.pdf[:templates][:first_page_template] = nil
      Rails.application.config.kavau.pdf[:templates][:following_page_template] = nil
    end

    after :each do
      Rails.application.config.kavau.pdf[:templates][:first_page_template] = nil
      Rails.application.config.kavau.pdf[:templates][:following_page_template] = nil
    end

    it "does not use a page template if none is given" do
      expect_any_instance_of(ApplicationPdf).not_to receive(:pdf_with_template)
      ApplicationPdf.new(@sender, @recipient).rendered
    end

    it "uses first page template for all pages if only first page template is given" do
      Rails.application.config.kavau.pdf[:templates][:first_page_template] = "#{Rails.root}/spec/support/templates/first_page.pdf"
      expect_any_instance_of(ApplicationPdf).to receive(:pdf_with_template).and_call_original
      pdf = ApplicationPdf.new(@sender, @recipient)
      expect(pdf.instance_variable_get('@first_page_template')).to eq(pdf.instance_variable_get('@following_page_template'))
      pdf.rendered
    end

    it "uses first page template for first page and following page template for others if both are given" do
      Rails.application.config.kavau.pdf[:templates][:first_page_template] = "#{Rails.root}/spec/support/templates/first_page.pdf"
      Rails.application.config.kavau.pdf[:templates][:following_page_template] = "#{Rails.root}/spec/support/templates/following_page.pdf"
      pdf = ApplicationPdf.new(@sender, @recipient)
      first_page_template = pdf.instance_variable_get('@first_page_template')
      following_page_template = pdf.instance_variable_get('@following_page_template')

      expect(first_page_template).not_to be_nil
      expect(following_page_template).not_to be_nil
      expect(first_page_template.to_s).not_to eq(following_page_template.to_s)
      
      expect_any_instance_of(ApplicationPdf).to receive(:pdf_with_template).and_return(:true)
      ApplicationPdf.new(@sender, @recipient).rendered
    end

    [:first_page_template, :following_page_template].each do |template|
      it "raises an Error if the #{template} is set but path is wrong" do
        Rails.application.config.kavau.pdf[:templates][template] = "wrong"
        expect(MissingTemplateError).to receive(:new).with(group: :templates, key: template).and_call_original
        expect{
          ApplicationPdf.new(@sender, @recipient)
        }.to raise_error(MissingTemplateError)
      end
    end
  end

  def reset_config
    Rails.application.config.kavau.pdf = {
      :colors=>{:color3=>"7c7b7f", :color1=>"009dc3", :color2=>"f9b625"}, 
      :margins=>{:bottom_margin=>3.5, :top_margin=>3.5, :right_margin=>2.0, :left_margin=>2.5}, 
      :templates=>{
        :logo=>"#{Rails.root}/spec/support/templates/logo.png", 
        :watermark=>"#{Rails.root}/spec/support/templates/stempel.png", 
        :first_page_template => nil, 
        :following_page_template => nil
      }, 
      :custom_font=>{
        :normal=>"#{Rails.root}/public/fonts/infotext_normal.ttf", 
        :italic=>"#{Rails.root}/public/fonts/infotext_italic.ttf", 
        :bold=>"#{Rails.root}/public/fonts/infotext_bold.ttf", 
        :bold_italic=>"#{Rails.root}/public/fonts/infotext_bold_italic.ttf",
      }, 
      :content=>{
        :saldo_information=>"additional information"
      }
    }
  end
end
