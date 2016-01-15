class PaymentsController < ApplicationController
  include LoadAuthorized
  include Searchable
  before_action :find_or_create_pdf, only: :show
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
      Pdf.create_with(creditor: @payment.credit_agreement.creditor, letter: PaymentLetter.first).find_or_create_by(payment: @payment)
    end

    def create_params
      permitted_params.merge(credit_agreement_id: params[:credit_agreement_id])
    end

    def set_type
      @payment = @payment.becomes(permitted_params[:type].constantize)
    end
end
