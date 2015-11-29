class LettersController < ApplicationController
  include Typed
  include LoadAuthorized

  def index
    @letters = Letter.all
    respond_with @letters
  end

  def show
    respond_with @letter
  end

  def new
    respond_with @letter
  end
  
  def edit
    respond_with @letter
  end

  def create
    @letter.save
    respond_with @letter
  end

  def update
    @letter.update(permitted_params)
    respond_with @letter
  end

  def destroy
    @letter.destroy
    respond_with @letter, location: '/letters'
  end

  private
    def klass
      @type.constantize
    end

    def required_params_key # overwrite LoadAuthorized#required_params_key
      @type.underscore.to_sym
    end
end
