module I18nKeyHelper
  def key_with_legal_form(address, attribute = nil)
    raise "not defined for #{address.class}" unless address.is_a?(Address)
    [address.type.underscore, address.legal_form, attribute].compact.join('.')
  end

  def missing_legal_information(address)
    raise "not defined for #{address.class}" unless address.is_a?(Address)
    address.missing_legals.map{|key| translated(key)}.to_sentence
  end

  def translated(key)
    key = key.join('_or_') if key.is_a?(Array)
    ProjectAddress.human_attribute_name(key) 
  end
end

