class ContactsController < ApplicationController
  @typed_associated_name = '@institution'
  include TypedAssociated
  include LoadAuthorized

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
    @contact.update(permitted_params)
    respond_with @contact, location: @contact.institution
  end

  def destroy
    @contact.destroy
    respond_with @contact, location: @contact.institution
  end

  private
    def create_params # overwrite LoadAuthorized#permitted_params
      permitted_params.merge(institution: @institution)
    end
end
