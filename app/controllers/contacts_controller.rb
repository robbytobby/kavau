class ContactsController < ApplicationController
  before_action :set_type
  before_action :set_institution
  include Authorized

  def new
    respond_with @contact
  end

  def edit
    respond_with @contact
  end

  def create
    @contact.save
    respond_with @contact, location: @contact.institution
  end

  def update
    @contact.update(contact_params)
    respond_with @contact, location: @contact.institution
  end

  def destroy
    @contact.destroy
    respond_with @contact, location: @contact.institution
  end

  private
    def contact_params
      params.require(:contact).permit(policy(@contact || Contact.new).permitted_params)
    end

    def create_params
      contact_params.merge(institution: @institution)
    end

    def set_institution
      @institution = @type.find(get_institution_id) 
    end

    def set_type
      @type = type.constantize
    end

    def type
      params[:type]
    end

    def get_institution_id
      params["#{type.underscore}_id"]
    end
end
