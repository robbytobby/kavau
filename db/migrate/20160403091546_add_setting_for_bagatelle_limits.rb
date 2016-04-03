class AddSettingForBagatelleLimits < ActiveRecord::Migration
  def up
    Setting.new(number: 0.3,
                category: 'legal_regulation',
                name: 'enforce_bagatelle_limits',
                type: 'BooleanSetting',
                obligatory: true,
                default: true,
                value: true
               ).save(validate: false)
    Setting.new(number: 0.4,
                category: 'legal_regulation',
                name: 'utilize_transitional_regulation',
                type: 'BooleanSetting',
                obligatory: true,
                default: true,
                value: true
               ).save(validate: false)
  end

  def down
    Setting.where(category: 'legal_regulation').delete_all
  end
end
