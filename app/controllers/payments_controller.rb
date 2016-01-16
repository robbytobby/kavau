class PaymentsController < ApplicationController
  include LoadAuthorized
  include Searchable
  before_action :check_template, :find_or_create_pdf, only: :show
  default_sort 'date desc'

  def index
    respond_with @payments
  end

  def show
    send_file @payment.pdf.path, type: 'application/pdf', disposition: :inline
  end

  def edit
    respond_with @payment
  end

  def create
    @payment.save
    @credit_agreement = @payment.credit_agreement
    respond_with @payment, location: @payment.credit_agreement do |format|
      format.js { render :new }
    end
  end

  def update
    set_type if permitted_params[:type]
    @payment.update(permitted_params)
    respond_with @payment, location: @payment.credit_agreement
  end

  def destroy
    @payment.destroy
    respond_with @payment, location: @payment.credit_agreement
  end

  private
    def find_or_create_pdf
      Pdf.create_with(creditor: @payment.credit_agreement.creditor, letter: @template).find_or_create_by(payment: @payment)
    end

    def check_template
      return if template
      flash[:alert] = I18n.t('payments.flash.no_template', name: letter_class.model_name.human)
      redirect_to letters_path 
    end
    
    def template
      @template = letter_class.first
    end

    def letter_class
      "#{@payment.class}Letter".constantize
    end

    def create_params
      permitted_params.merge(credit_agreement_id: params[:credit_agreement_id])
    end

    def set_type
      @payment = @payment.becomes(permitted_params[:type].constantize)
    end
end
