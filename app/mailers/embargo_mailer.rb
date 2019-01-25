# frozen_string_literal: true
class EmbargoMailer < ApplicationMailer
  def notify(email, doc_name, days_left)
  	##
  	# takes in the email of a user, the work thats embargo is expiring and 
  	# the days remaining untill the embargo is expired. then sends mail to
  	# the user warning them of impending doom.
  	# sends from the default :from defined in Application Mailer.
    mail(
          to: [email, ENV['MAILUSER']],# TODO who should be CC'd in this
          subject: 'Embargoed Work Reminder', # TODO 
          body: "The work titled \"#{doc_name}\" is about to expire in #{days_left} #{'day'.pluralize(days_left)}"
        )
  end
end
