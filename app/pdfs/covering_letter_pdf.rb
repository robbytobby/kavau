class CoveringLetterPdf < ApplicationPdf
  def initialize(balance)
    @balance = balance
    super @balance.credit_agreement.account.address, @balance.creditor
  end

  private
  def content
    move_cursor_to 16.cm
    salutation
    move_down 10
    main_content
    thanks
  end

  def salutation
    text I18n.t(@recipient.salutation.downcase.to_sym, scope: [:pdf, :salutation], name: @recipient.full_name(:informal)) + ','
  end

  def main_content
    text 'wieder ist ein Jahr zuende und wir existieren immer noch. 
          Anbei findest du den Jahresabschluss für 2014 und die dazugehörige Zinsbescheinigung'
  end
  
  def thanks
    text 'Wir bedanken uns für die Unterstützung und wünschen ein fröhliches neues Jahr
          Die Lamakat GmbH'
  end
  

end
