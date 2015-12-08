module LettersHelper
  def placeholder(letter, attr)
    t attr, scope: [:simple_form, :placeholders, @letter.type.underscore]
  end
end
