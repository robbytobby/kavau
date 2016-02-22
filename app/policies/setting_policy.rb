class SettingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? Setting.all : Setting.none
    end
  end

  def index?
    user.admin?
  end

  def show?
    false
  end

  def new?
    false
  end
  
  def create?
    new?
  end

  def edit?
    false
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def permitted_params
    [:value]
  end
end

class StringSettingPolicy < SettingPolicy
end
class TextSettingPolicy < SettingPolicy
end
class IntegerSettingPolicy < SettingPolicy
end
class FloatSettingPolicy < SettingPolicy
end
class BooleanSettingPolicy < SettingPolicy
end
class ArraySettingPolicy < SettingPolicy
end
class FileSettingPolicy < SettingPolicy
  def permitted_params
    [:attachment]
  end
end
