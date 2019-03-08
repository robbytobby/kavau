FactoryBot.define do
  factory :setting do
    category "Category"
    name "SettingName"

    factory :array_setting, class: ArraySetting do
    end

    factory :boolean_setting, class: BooleanSetting do
      value 'true'
    end

    factory :file_setting, class: FileSetting do
    end

    factory :float_setting, class: FloatSetting do
    end

    factory :integer_setting, class: IntegerSetting do
    end

    factory :string_setting, class: StringSetting do
    end

    factory :text_setting, class: TextSetting do
    end
  end
end
