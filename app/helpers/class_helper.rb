module ClassHelper
  def nav_class(item, condition = true)
     condition && controller.controller_name == item ? 'active' : ''
  end
end
  
