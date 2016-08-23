module DepartmentsHelper

  def accessible_departments
    Department.accessible_by(current_user).ordered
  end
end
