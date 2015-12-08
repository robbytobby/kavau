class LettersController < ApplicationController
  include Typed
  include LoadAuthorized

  def index
    @letters = @letters.includes(:pdfs)
    respond_with @letters
  end

  def show
    respond_with @letter do |format|
      format.html
      format.pdf { send_data LetterPdf.new(Address.creditors.first, @letter).render, type: 'application/pdf', disposition: :inline  }
    end
  end

  def new
    respond_with @letter
  end
  
  def edit
    respond_with @letter
  end

  def create
    @letter.save
    respond_with @letter, location: '/letters'
  end

  def update
    @letter.update(permitted_params)
    respond_with @letter, location: '/letters'
  end

  def destroy
    @letter.destroy
    respond_with @letter, location: '/letters'
  end

  def get_pdfs
    send_data @letter.combined_pdf, filename: "#{@letter.title}.pdf", type: 'application/pdf', disposition: :attachment
  end

  def create_pdfs
    #TODO nur wo pdf noch nicht existiert
    @letter.create_pdfs
    flash[:notice] = I18n.t('letters.flash.pdfs_created')
    respond_with(@letter, location: letters_path)
  end

  private
    def klass
      @type.constantize
    end

    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end
end
