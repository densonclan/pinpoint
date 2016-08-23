module TasksHelper

  def priorityText(val)
    case val
      when 0 then return "Normal"
      when 1 then return "High"
      when 2 then return "Urgent"
    end
  end

    def tasks_menu_class(selected)
        selected == params[:action] ? 'active' : nil
    end

    def task_priority_options
        [['Normal',0],['High',1],['Urgent', 2]]
    end        

    def task_assigned_title
        "Assigned #{action_for_user? ? 'by' : 'to'}"
    end

    def task_assigned_value(t)
        action_for_user? ? 
            t.user.name :
            t.agent ?
                t.agent.name :
                t.department ?
                    "#{t.department.name} department" :
                    '-'
    end

    def action_for_user?
        params[:action].to_sym != :assigned
    end

    def due_date_class(task)
        class_name = ''
        difference = (task.due_date.to_date - Date.today).to_i

        if difference <= 0
            class_name = 'error'
        elsif difference < 5 && difference > 0
            class_name = 'warning'
        end
    end

    def task_label_class(task)
        class_name = ''
        difference = (task.due_date.to_date - Date.today).to_i

        if difference <= 0
            class_name = 'label-important'
        elsif difference < 5 && difference > 0
            class_name = 'label-warning'
        end
    end
end
