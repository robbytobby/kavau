class CreditAgreementsController < ApplicationController
  include Typed
  include LoadAuthorized

  def index
    respond_with @credit_agreements
  end

  def show
    respond_with @credit_agreement
  end

  def new
    respond_with @credit_agreement
  end

  def edit
    respond_with @credit_agreement
  end

  def create
    @credit_agreement.save
    respond_with @credit_agreement, location: @credit_agreement.creditor
  end

  def update
    @credit_agreement.update(permitted_params)
    respond_with @credit_agreement, location: -> { after_action_path }
  end

  def destroy
    @credit_agreement.destroy
    respond_with @credit_agreement, location: -> { after_action_path }
  end

  private
    def typed_association
      '@creditor'
    end

    def create_params
      permitted_params.merge(creditor: @creditor)
    end

    def after_action_path
      session[:back_url] || credit_agreements_path
    end
end