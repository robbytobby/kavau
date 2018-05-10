class CreditAgreementsController < ApplicationController
  include TypedAssociated
  include LoadAuthorized
  include Searchable
  default_sort 'number asc'
  @typed_associated_name = '@creditor'
  respond_to :xlsx

  skip_before_action :set_type, only: [:index, :show, :create_yearly_balances]
  skip_before_action :set_associated, only: [:index, :show, :create_yearly_balances]
  skip_before_action :find_record, only: :create_yearly_balances
  skip_before_action :authorize_record, only: :create_yearly_balances

  def index
    respond_with @credit_agreements, filename: CreditAgreement.model_name.human.pluralize(I18n.locale)
  end

  def show
    respond_with @credit_agreement
  end

  def new
    raise NoAccountError if Account.where(address_type: 'ProjectAddress').none?
    respond_with @credit_agreement  end

  def edit
    respond_with @credit_agreement
  end

  def create
    @credit_agreement.save
    respond_with @credit_agreement, location: @credit_agreement.creditor
  end

  def update
    if @credit_agreement.update(permitted_params)
      respond_with @credit_agreement, location: -> { after_action_path }
    else
      flash[:alert] = I18n.t('flash.actions.update.alert', resource_name: CreditAgreement.model_name.human)
      render edit_template
    end
  end

  def destroy
    @credit_agreement.destroy
    respond_with @credit_agreement, location: -> { after_action_path }
  end

  def create_yearly_balances
    authorize CreditAgreement, :create_yearly_balances?
    CreditAgreement.create_yearly_balances
    flash[:notice] = I18n.t('credit_agreements.flash.create_yearly_balances')
    redirect_to root_path
  end

  private
    def create_params # overwrite LoadAuthorized#permitted_params
      permitted_params.merge(creditor: @creditor)
    end

    def after_action_path
      session[:back_url] || credit_agreements_path
    end
    
    def edit_template 
      @credit_agreement.errors[:terminated_at].blank? ? 'edit' : 'show'
    end
end
