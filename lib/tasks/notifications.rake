require 'rake'

namespace :check do

    #
    # Check if the period is almost complete
    #
    task :orders => :environment do
        #
        # Load current Period
        #
        @period = Period.current

        #
        # Find out how many days left until the promotion
        #
        if @period.orders.for_status(1).count > 0
            completed = (@period.orders.count / @period.orders.for_status(1).count).ceil
            puts "#{completed} % out of #{@period.orders.count}"

            #
            # If the % of completion is near
            #
            if completed > 75
                department = Department.find_by_name('Administrator')
                due_date = @period.date_dispatch + 3
                message_text = "Please review the changes for the next period and close the period ##{@period.period_number}"

                #
                # Check if task already been sent
                #
                if Task.where('due_date = ? AND full_text = ?',due_date, message_text).blank?

                    task = Task.new(:department_id => department.id, :for_department => true, :due_date => due_date, :full_text => message_text, :user_id => 1)
                    if task.save
                        puts "Task assigned"
                    else
                        puts "#{task.errors.to_a}"
                    end

                else
                    puts 'Already sent'
                end

            else
                puts "Not completed enough"
            end
        end
    end

    #
    # Check if the period's promo date is almost done.
    #
    task :dates => :environment do

        #
        # Load current Period
        #
        @period = PeriodDates.for_current_period.first

        #
        # Get dates
        #
        promo_date = @period.date_promo.to_date
        promo_days_left = (promo_date - Date.today).to_i

        dispatch_date = @period.date_dispatch.to_date
        dispatch_days_left = (dispatch_date - Date.today).to_i

        #
        # Print out days lest
        #
        puts "Promo: #{promo_days_left}"
        puts "Dispatch: #{dispatch_days_left}"

        #
        # If the dates are closer.
        #
        if promo_days_left < 7 || dispatch_days_left < 7

            department = Department.find_by_name('Administrator')
            due_date = @period.date_dispatch + 3
            message_text = "Please review the changes for the next period and close the period ##{@period.period_number}"

            #
            # Check if task already been sent
            #
            if Task.where('due_date = ? AND full_text = ?',due_date, message_text).blank?

                task = Task.new(:department_id => department.id, :for_department => true, :due_date => due_date, :full_text => message_text, :user_id => 1)
                if task.save
                    MessageMailer.task_notification(task).deliver
                    puts "Task assigned"
                else
                    puts "#{task.errors.to_a}"
                end

            else
                puts 'Already sent'
            end

        else
            puts "Too soon to compile the period."
        end

    end

    task :due_tasks => :environment do
        Task.notify_overdue_tasks
    end
end