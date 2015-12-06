class PdfsController < ApplicationController
  include TypedAssociated
  include LoadAuthorized
  @typed_associated_name = '@address'
  skip_before_action :set_associated, except: [:new, :create]

  def show
    send_file @pdf.path, type: 'application/pdf', disposition: :inline
  end

  def new
    respond_with @pdf
  end

  def create
    @pdf.save
    respond_with @pdf, location: @pdf.creditor
  end

  def update
    @pdf.update_file
    respond_with @pdf, location: @pdf.creditor
  end

  def destroy
    @pdf.destroy
    respond_with @pdf, location: @pdf.creditor
  end

  private
    def required_params_key
      return nil if action_name == 'update'
      :pdf
    end

    def create_params # overwrite LoadAuthorized#permitted_params
      permitted_params.merge(creditor: @address)
    end
end
