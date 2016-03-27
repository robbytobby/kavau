# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.singular /^(ox)en/i, '\1'
  inflect.uncountable %w( fish sheep )
end
#
## These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:de) do |inflect|
  inflect.plural /in$/, 'innen'
  inflect.plural /ag$/, 'äge'
  inflect.plural /ung$/, 'ungen'
  inflect.irregular 'Saldo', 'Salden'
end
