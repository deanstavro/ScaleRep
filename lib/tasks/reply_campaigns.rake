desc "This task is called by the Heroku scheduler add-on"
task :reply_campaigns => :environment do
  GetCampaignsFromReplyJob.perform_now()
end