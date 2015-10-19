class ContactsController < ApplicationController
  before_action :set_type
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :set_institution

  def new
    @contact = Contact.new
    authorize @contact
    respond_with @contact
  end

  def edit
    respond_with @contact
  end

  def create
    @contact = Contact.new(contact_params.merge(institution: @institution))
    authorize @contact
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
    def set_contact
      @contact = Contact.find(params[:id])
      authorize @contact
    end

    def contact_params
      params.require(:contact).permit(policy(@contact || Contact.new).permitted_params)
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
