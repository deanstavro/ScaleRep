desc "This task is called by the Heroku scheduler add-on"
task :referral_to_reply => :environment do
  ReferralsToReplyJob.perform_now()
end
