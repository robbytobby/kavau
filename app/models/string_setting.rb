class StringSetting < Setting
  def form_field
    return :password if name == 'password'
    :string
  end
end
