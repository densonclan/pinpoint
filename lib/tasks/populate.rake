require 'rake'

namespace :populate do

    #
    # Check if the period is almost complete
    #
    task :periods => :environment do

        #
        # Periods
        #
        first_period = Period.new({
            :period_number => 1,
            :week_number => 298,
            :completed => false,
            :current => false
        })

        first_period.period_dates.build({
            :client_id => nil,
            :date_promo => '12-12-2012',
            :date_samples => '12-12-2012',
            :date_approval => '12-12-2012',
            :date_print => '12-12-2012',
            :date_dispatch => '12-12-2012'
        })

        if first_period.save
            puts "Period 1 created."
        else
            puts "ERROR: #{first_period.errors.to_a}"
        end

        #
        # Create periods from 2 to 17
        #
        (2..17).each do |i|

            first_period = Period.new({
                :period_number => i,
                :week_number => (first_period.week_number + 3),
                :completed => false,
                :current => false
            })

            first_period.period_dates.build({
                :date_promo => (first_period.date_promo.to_date + 21),
                :date_samples => (first_period.date_samples.to_date + 21),
                :date_approval => (first_period.date_approval.to_date + 21),
                :date_print => (first_period.date_print.to_date + 21),
                :date_dispatch => (first_period.date_dispatch.to_date + 21)
            })

            if first_period.save
                puts "Period #{i}: Created."
            else
                puts "Period #{i}: #{first_period.errors.to_a}"
            end

        end

    end

end