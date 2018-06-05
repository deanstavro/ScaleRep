desc "This task is called by the Heroku scheduler add-on"
task :auto_reply_to_reply => :environment do
  AutoRepliesToReplyIoJob.perform_now()
end
