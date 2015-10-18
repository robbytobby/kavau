class ContactsController < ApplicationController
  before_action :set_type
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :set_organization

  def new
    @contact = Contact.new
    authorize @contact
    respond_with @contact
  end

  def edit
    respond_with @contact
  end

  def create
    @contact = Contact.new(contact_params.merge(organization_id: get_organization_id))
    authorize @contact
    @contact.save
    respond_with @contact, location: @contact.organization
  end

  def update
    @contact.update(contact_params)
    respond_with @contact, location: @contact.organization
  end

  def destroy
    @contact.destroy
    respond_with @contact, location: @contact.organization
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
      authorize @contact
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(policy(@contact || Contact.new).permitted_params)
    end

    def set_organization
      @organization = @type.find(get_organization_id) 
    end

    def set_type
      @type = params[:type].constantize
    end

    def get_organization_id
      params[:organization_id] || params[:project_address_id]
    end
end
